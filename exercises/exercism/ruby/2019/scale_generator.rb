# Scale Generator from https://exercism.io

class Scale
  CHROMATICS = {
    sharp: %w[A A# B C C# D D# E F F# G G#],
    flat:  %w[A Bb B C Db D Eb E F Gb G Ab]
  }.freeze

  KEYS = {
    sharp: %w[C G D A E B F# a e b f# c# g# d#],
    flat:  %w[F Bb Eb Ab Db Gb d g c f bb eb]
  }.freeze

  INTERVALS = {
    'm' => 1,
    'M' => 2,
    'A' => 3
  }.freeze

  def initialize(tonic, scale, pattern = 'm' * 12)
    @tonic = tonic
    @scale = scale
    @pattern = pattern
    @position = 0
  end

  def name
    "#{tonic.capitalize} #{scale.to_s}"
  end

  def pitches
    steps.each_with_object([]) do |step, arr|
      arr << chromatic[@position]
      @position += step
    end
  end

  private

    attr_reader :tonic, :scale, :pattern

    def steps
      pattern.chars.map(&INTERVALS)
    end

    def key_signature
      KEYS.key(KEYS.values.find { |v| v.include? tonic })
    end

    def chromatic
      CHROMATICS[key_signature].then { |chrom| chrom.rotate(chrom.index(tonic.capitalize)) }
    end
