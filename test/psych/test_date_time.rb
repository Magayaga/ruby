# frozen_string_literal: true
require_relative 'helper'

module Psych
  class TestDateTime < TestCase
    def test_negative_year
      time = Time.utc(-1, 12, 16)
      assert_cycle time
    end

    def test_usec
      time = Time.utc(2017, 4, 13, 12, 0, 0, 5)
      assert_cycle time
    end

    def test_non_utc
      time = Time.new(2017, 4, 13, 12, 0, 0.5, "+09:00")
      assert_cycle time
    end

    def test_timezone_offset
      times = [Time.new(2017, 4, 13, 12, 0, 0, "+09:00"),
               Time.new(2017, 4, 13, 12, 0, 0, "-05:00")]
      cycled = Psych::unsafe_load(Psych.dump times)
      assert_match(/12:00:00 \+0900/, cycled.first.to_s)
      assert_match(/12:00:00 -0500/,  cycled.last.to_s)
    end

    def test_new_datetime
      assert_cycle DateTime.new
    end

    def test_datetime_non_utc
      dt = DateTime.new(2017, 4, 13, 12, 0, 0.5, "+09:00")
      assert_cycle dt
    end

    def test_datetime_timezone_offset
      times = [DateTime.new(2017, 4, 13, 12, 0, 0, "+09:00"),
               DateTime.new(2017, 4, 13, 12, 0, 0, "-05:00")]
      cycled = Psych::unsafe_load(Psych.dump times)
      assert_match(/12:00:00\+09:00/, cycled.first.to_s)
      assert_match(/12:00:00-05:00/,  cycled.last.to_s)
    end

    def test_julian_date
      d = Date.new(1582, 10, 4, Date::GREGORIAN)
      assert_cycle d
    end

    def test_proleptic_gregorian_date
      d = Date.new(1582, 10, 14, Date::GREGORIAN)
      assert_cycle d
    end

    def test_julian_datetime
      dt = DateTime.new(1582, 10, 4, 23, 58, 59, 0, Date::GREGORIAN)
      assert_cycle dt
    end

    def test_proleptic_gregorian_datetime
      dt = DateTime.new(1582, 10, 14, 23, 58, 59, 0, Date::GREGORIAN)
      assert_cycle dt
    end

    def test_invalid_date
      assert_cycle "2013-10-31T10:40:07-000000000000033"
    end

    def test_string_tag
      dt = DateTime.now
      yaml = Psych.dump dt
      assert_match(/DateTime/, yaml)
    end

    def test_round_trip
      dt = DateTime.now
      assert_cycle dt
    end

    def test_alias_with_time
      t    = Time.now
      h    = {:a => t, :b => t}
      yaml = Psych.dump h
      assert_match('&', yaml)
      assert_match('*', yaml)
    end

    def test_overwritten_to_s
      pend "Failing on JRuby" if RUBY_PLATFORM =~ /java/
      s = Psych.dump(Date.new(2023, 9, 2), permitted_classes: [Date])
      assert_separately(%W[-rpsych -rdate - #{s}], "#{<<~"begin;"}\n#{<<~'end;'}")
      class Date
        undef to_s
        def to_s; strftime("%D"); end
      end
      expected = ARGV.shift
      begin;
        s = Psych.dump(Date.new(2023, 9, 2), permitted_classes: [Date])
        assert_equal(expected, s)
      end;
    end
  end
end
