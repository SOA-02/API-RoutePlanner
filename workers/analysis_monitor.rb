# frozen_string_literal: true

module RoutePlanner
  # Infrastructure to analyze while yielding progress
  module AnalysisMonitor
    ANALYSIS_PROGRESS = {
      'STARTED'   => 15,
      'Analyzing' => 30,
      'remote'    => 70,
      'Receiving' => 85,
      'Resolving' => 90,
      'Checking'  => 95,
      'FINISHED'  => 100
    }.freeze
  end

  def self.starting_percent
    ANALYSIS_PROGRESS['STARTED'].to_s
  end

  def self.finished_percent
    ANALYSIS_PROGRESS['FINISHED'].to_s
  end

  def self.progress(line)
    ANALYSIS_PROGRESS[first_word_of(line)].to_s
  end

  def self.percent(stage)
    ANALYSIS_PROGRESS[stage].to_s
  end

  def self.first_word_of(line)
    line.match(/^[A-Za-z]+/).to_s
  end
end
