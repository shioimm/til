## client/pool.rb
https://github.com/nurse/net-http/blob/8ac46b06f4c63388d03c59a1f05c036a9e8a99b3/lib/net/http/client/pool.rb

```ruby
# frozen_string_literal: true
module Net
  class HTTP
    class Client
      # The process pool knows only reservation/release, close, idle state and route.
      # Protocol sessions own stream credit and the meaning of a reservation.
      class Pool
        # Client::Pool::Entry
        Entry = Struct.new(:key, :session, :used_at, :origin)

        def initialize(max_connections: 100, max_connections_per_origin: 10, idle_timeout: 30)
          @limit, @origin_limit, @idle_timeout = max_connections, max_connections_per_origin, idle_timeout
          @pid = Process.pid
          @mutex = Mutex.new
          @entries, @connecting, @connecting_origins = [], {}, {}
          @closed = false
          @next_reap = 0
        end

        # Client::Pool#acquire
        def acquire(key, operation, origin: key) # origin = scheme・ホスト名・ポート
          reset_after_fork # => Client::Pool#reset_after_fork
          deadline = nil

          # ループの終了条件
          #   - プール内の既存Sessionを予約できた場合
          #   - 新規接続のSessionを予約できた場合
          loop do
            # キャンセル済みならCancelledError、タイムアウト済みならRequestTimeoutを発生させる
            operation.check! # => Client::Operation#check!

            create = false

            lease = @mutex.synchronize {
              raise ClosedError, 'connection pool shut down' if @closed # プールがシャットダウン済み

              reap # => Client::Pool#reap 使えなくなったSessionや待機期限を過ぎたSessionを一覧から取り除く
              found = nil # 既存の接続の探索結果 [Entry, 予約情報] を格納する

              # プールが保持するEntryを走査
              @entries.each do |entry|
                # Entryの接続共有キーが今回のリクエストのキーと一致しなければスキップ
                next if entry.key != key

                # Sessionに利用予約を依頼
                reservation = entry.session.reserve
                # => - Client::H1Session#reserve Sessionをbusy状態として記録し、trueを返す
                #    - Client::H2::Session#reserve 新しいStreamを作って返す

                # 予約できたらEntryと予約情報をfoundに格納
                if reservation
                  found = [entry, reservation]
                  break
                else
                  # そのSessionに新しいリクエストを受け入れる枠がない、または終了済みの場合は予約に失敗する
                  #   - H1Sessionの場合、リクエスト枠は一つ
                  #   - H2::Sessionの場合、リクエスト枠はストリーム数の上限値
                end
              end

              # 予約できるSessionが見つからなかった場合
              unless found
                origin_count =
                  @entries.count { |e| e.origin == origin } + # プールに登録済みのEntry数
                  @connecting_origins.fetch(origin, 0) # 現在作成中の接続数

                # 今回のoriginの接続数が上限以上の場合
                if origin_count >= @origin_limit
                  # 新しい接続のために枠を空けたい

                  idle = @entries.select { |e|
                    # 今回と同じoriginかつ現在予約されていないSessionかつ今回の設定で再利用できない別の共有キー
                    e.origin == origin && e.session.idle? && e.key != key
                  }.min_by(&:used_at) # ...のうち、最終使用時刻が最も古いEntry

                  if idle
                    @entries.delete(idle) # Entryをプールから削除
                    idle.session.close # Sessionを閉じる
                    origin_count -= 1 # 接続数を減らす
                  end
                end

                # 今回のoriginの接続数が上限未満かつ同じ共有キーで作成中の接続がない場合
                if origin_count < @origin_limit && @connecting.fetch(key, 0).zero?
                  # @connecting = 共有キーごとの接続作成中の数を保持するHash

                  # 登録済みの接続数 + 作成中の接続数が上限数を超えている場合
                  if @entries.size + @connecting.values.inject(0, :+) >= @limit
                    # Entryのうち待機中かつ前回の接続が最も古いものを取得して削除
                    idle = @entries.select { |e| e.session.idle? }.min_by(&:used_at)

                    if idle
                      @entries.delete(idle)
                      idle.session.close
                    end
                  end

                  # 登録済みの接続数 + 作成中の接続数が上限数未満の場合
                  if @entries.size + @connecting.values.inject(0, :+) < @limit
                    # 接続作成中の数を登録
                    @connecting[key] = @connecting.fetch(key, 0) + 1
                    @connecting_origins[origin] = @connecting_origins.fetch(origin, 0) + 1
                    create = true # 接続枠を確保
                  end
                end
              end
              found
            }

            return lease if lease # [Entry, 予約情報] もしくはnil

            if create # 接続枠が確保されている場合
              session = nil # これから作るSessionを格納する
              registered = false # そのSessionをプールへ登録できたかどうか

              begin
                # #acquireに渡されたブロックを実行
                #   e.g. ConnectionFactory.open(attempt, options, operation, proxy)
                session = yield # 接続を確立し、H1SessionまたはHTTP2::Sessionを取得してsessionに格納する

                # 接続作成中にキャンセルや期限切れが起きていないか確認
                operation.check! # => Client::Operation#check!

                # プールをロックしてEntryを登録
                lease = @mutex.synchronize {
                  raise ClosedError, 'connection pool shut down' if @closed

                  entry = Entry.new(key, session, Clock.now, origin)
                  @entries << entry
                  registered = true

                  # Sessionに利用予約を依頼
                  reservation = session.reserve
                  # => - Client::H1Session#reserve Sessionをbusy状態として記録し、trueを返す
                  #    - Client::H2::Session#reserve 新しいStreamを作って返す

                  reservation ? [entry, reservation] : nil
                }

                return lease if lease
              ensure
                # 成功・失敗にかかわらず、接続作成のためく確保していた枠を解除
                @mutex.synchronize {
                  # 共有キー単位の作成中カウントを減らす
                  count = @connecting.fetch(key, 1) - 1

                  if count.zero?
                    @connecting.delete(key)
                  else
                    @connecting[key] = count
                  end

                  # origin単位の作成中カウントを減らす
                  origin_count = @connecting_origins.fetch(origin, 1) - 1

                  if origin_count.zero?
                    @connecting_origins.delete(origin)
                  else
                    @connecting_origins[origin] = origin_count
                  end
                }

                # Sessionを作ったがプールへ登録できなかった場合はSessionを閉じる
                session.close if session && !registered
              end
            end

            # 既存・新規のどちらのSessionも予約できず、return leaseできなかった場合

            # プールが接続を待つ期限を取得
            deadline ||= Clock.now + operation.remaining(operation.options[:pool_timeout])
            # プールをロックし、今回の共有キーと一致するEntryからSessionを取得
            sessions = @mutex.synchronize { @entries.select { |e| e.key == key }.map(&:session) }

            begin
              sessions.each do |session|
                session.progress(operation) if session.respond_to?(:progress)
                # SessionがH1Sessionの場合: #progressが存在しないので何もしない
                # SessionがHTTP2::Sessionの場合: => HTTP2::Session#process ソケットの読み取りやフレーム処理を進める
                #                                   処理が進むことで次の探索では予約できるようになる可能性がある
              end

            rescue StandardError
              @mutex.synchronize do
                @entries.delete_if { |entry| entry.session.closed? }
              end
              raise
            end

            # キャンセルと期限を確認して待機
            Wait.pause(operation, deadline) # => Client::Wait.pause ()
          end
        end

        # Client::Pool#release
        def release(entry, reservation)
          entry.session.release(reservation)

          @mutex.synchronize do
            entry.used_at = Clock.now

            if @closed || entry.session.closed?
              @entries.delete(entry)
              entry.session.close
            end
          end
        end

        def shutdown
          reset_after_fork
          sessions = @mutex.synchronize do
            @closed = true
            @entries.map(&:session).tap { @entries.clear }
          end
          sessions.each(&:close)
        end

        def stats
          reset_after_fork
          @mutex.synchronize do
            {connections: @entries.size, connecting: @connecting.values.inject(0, :+),
             active: @entries.count { |e| !e.session.idle? }}.freeze
          end
        end

        private

        # Client::Pool#reap
        # 使用できないSessionを閉じ、そのSessionを保持するEntryをプールから削除
        def reap
          now = Clock.now
          return if now < @next_reap

          @next_reap = now + @idle_timeout # 現在から@idle_timeout後

          @entries.delete_if do |entry|
            expired =
              # Sessionがすでに閉じている
              entry.session.closed? ||
              # Sessionの最後の利用から@idle_timeout以上経過
              (entry.session.idle? && now - entry.used_at >= @idle_timeout)

            entry.session.close if expired
            expired
          end

          # 残ったEntryのうち待機中のものを選び、それぞれの期限を計算して最も早い時刻を取得
          nearest = @entries.filter_map { |entry| entry.used_at + @idle_timeout if entry.session.idle? }.min

          @next_reap = nearest || now + @idle_timeout
        end

        # Client::Pool#reset_after_fork
        def reset_after_fork
          return if @pid == Process.pid

          # No inherited mutex may be acquired in a forked child.

          # アプリケーションがforkされている場合 = プロセスIDが変わっていた場合、
          # fork後のPoolの状態を確認し、接続を待つ期限の変数を準備する

          # 親から引き継いだソケットを子プロセス側で破棄
          @entries.each { |entry| entry.session.discard_after_fork }
          # => - Client::H1Session#discard_after_fork
          #    - Client::H2::Session#discard_after_fork

          # Poolの接続一覧・接続作成中の記録・Mutexなどを初期化
          @entries = []
          @connecting = {}
          @connecting_origins = {}
          @mutex = Mutex.new
          @closed = false
          @next_reap = 0
          @pid = Process.pid
        end
      end
      private_constant :Pool
    end
  end
end
```
