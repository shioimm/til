# cgroupfs
- cgroupを管理する仮想ファイルシステム
  - cgroup - 一つあるいは複数個のプロセスからなるグループにリソース使用量の制限をかける
  - cgroupで制限をかけられるリソース - e.g. CPU、メモリ
- `/sys/fs/cgroup`以下に各cgroupコントローラに対するcgroupファイルシステムがマウントされている
- サブシステム (各リソースを管理するカーネルのコンポーネント) への設定を行うために用いられる
- ディレクトリに沿った階層構造になっており、
  各ディレクトリが各control group (制限の対象となるプロセスの集合) に対応する
  - 各プロセスはいずれかのcontrol groupに所属する
  - 各ディレクトリのファイルを通じて設定を適用する
    - 上位のcgroupの設定は下位のcgroupへ引き継がれる
    - 下位のcgroupは上位のcgroupによって設定された制限を超えない
