class WeeklyOgpImageService
  FONT = Rails.root.join("vendor/fonts/NotoSansCJK-Regular.ttc").to_s
  WIDTH = 1200
  HEIGHT = 630
  BG_COLOR = "#1e1b4b"
  ACCENT_COLOR = "#818cf8"
  BAR_COLOR = "#818cf8"
  BAR_BG_COLOR = "#2d2a5e"
  BAR_MAX_WIDTH = 700

  def initialize(week_start:, week_end:, summary:, total_minutes:)
    @week_start = week_start
    @week_end = week_end
    @summary = summary
    @total_minutes = total_minutes
  end

  def call
    tmpfile = Tempfile.new(["weekly_ogp", ".png"])
    args = base_args + content_args + [tmpfile.path]

    success = system("convert", *args)
    raise "OGP image generation failed" unless success

    tmpfile
  end

  private

  def base_args
    [
      "-size", "#{WIDTH}x#{HEIGHT}",
      "xc:#{BG_COLOR}",
      "-font", FONT,
    ]
  end

  def content_args
    args = []

    week_range = "#{@week_start.strftime('%Y年%-m月%-d日')} 〜 #{@week_end.strftime('%-m月%-d日')}"

    # Study-keeper ラベル
    args += ["-pointsize", "28", "-fill", ACCENT_COLOR, "-draw", "text 60,70 'Study-keeper'"]

    # 週の期間
    args += ["-fill", "white", "-pointsize", "46", "-draw", "text 60,148 '#{week_range}'"]

    # 区切り線
    args += ["-fill", ACCENT_COLOR, "-draw", "rectangle 60,165 #{WIDTH - 60},168"]

    if @total_minutes == 0
      args += ["-fill", "#aaaacc", "-pointsize", "40", "-draw", "text 60,280 'この週の記録はありません'"]
    else
      h = @total_minutes / 60
      m = @total_minutes % 60
      total_text = h > 0 ? "#{h}時間#{m}分" : "#{m}分"

      args += ["-fill", "#aaaacc", "-pointsize", "30", "-draw", "text 60,230 '合計時間'"]
      args += ["-fill", "white", "-pointsize", "72", "-draw", "text 60,310 '#{total_text}'"]

      @summary.first(3).each_with_index do |s, i|
        y_base = 390 + i * 70
        bar_width = (s[:percentage].to_f / 100 * BAR_MAX_WIDTH).round.clamp(4, BAR_MAX_WIDTH)
        name = s[:activity_name].to_s.slice(0, 10)
        time_text = "#{s[:total_minutes] / 60}時間#{s[:total_minutes] % 60}分 (#{s[:percentage]}%)"

        args += ["-fill", BAR_BG_COLOR, "-draw", "rectangle 60,#{y_base} #{60 + BAR_MAX_WIDTH},#{y_base + 28}"]
        args += ["-fill", BAR_COLOR,    "-draw", "rectangle 60,#{y_base} #{60 + bar_width},#{y_base + 28}"]
        args += ["-fill", "white",      "-pointsize", "26", "-draw", "text 60,#{y_base - 8} '#{name}'"]
        args += ["-fill", "#aaaacc",    "-pointsize", "24", "-draw", "text #{60 + BAR_MAX_WIDTH + 16},#{y_base + 22} '#{time_text}'"]
      end
    end

    args
  end
end
