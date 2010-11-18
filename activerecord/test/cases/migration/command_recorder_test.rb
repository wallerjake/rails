require "cases/helper"

module ActiveRecord
  class Migration
    class CommandRecorderTest < ActiveRecord::TestCase
      def setup
        @recorder = CommandRecorder.new
      end

      def test_record
        @recorder.record :create_table, [:system_settings]
        assert_equal 1, @recorder.commands.length
      end

      def test_inverse
        @recorder.record :create_table, [:system_settings]
        assert_equal 1, @recorder.inverse.length

        @recorder.record :rename_table, [:old, :new]
        assert_equal 2, @recorder.inverse.length
      end

      def test_inverted_commands_are_reveresed
        @recorder.record :create_table, [:hello]
        @recorder.record :create_table, [:world]
        tables = @recorder.inverse.map(&:last)
        assert_equal [[:world], [:hello]], tables
      end

      def test_invert_create_table
        @recorder.record :create_table, [:system_settings]
        drop_table = @recorder.inverse.first
        assert_equal [:drop_table, [:system_settings]], drop_table
      end

      def test_invert_rename_table
        @recorder.record :rename_table, [:old, :new]
        rename = @recorder.inverse.first
        assert_equal [:rename_table, [:new, :old]], rename
      end

      def test_invert_add_column
        @recorder.record :add_column, [:table, :column, :type, {}]
        remove = @recorder.inverse.first
        assert_equal [:remove_column, [:table, :column]], remove
      end

      def test_invert_rename_column
        @recorder.record :rename_column, [:table, :old, :new]
        rename = @recorder.inverse.first
        assert_equal [:rename_column, [:table, :new, :old]], rename
      end

      def test_invert_add_index
        @recorder.record :add_index, [:table, [:one, :two], {:options => true}]
        remove = @recorder.inverse.first
        assert_equal [:remove_index, [:table, {:column => [:one, :two]}]], remove
      end

      def test_invert_rename_index
        @recorder.record :rename_index, [:old, :new]
        rename = @recorder.inverse.first
        assert_equal [:rename_index, [:new, :old]], rename
      end

      def test_invert_add_timestamps
        @recorder.record :add_timestamps, [:table]
        remove = @recorder.inverse.first
        assert_equal [:remove_timestamps, [:table]], remove
      end

      def test_invert_remove_timestamps
        @recorder.record :remove_timestamps, [:table]
        add = @recorder.inverse.first
        assert_equal [:add_timestamps, [:table]], add
      end
    end
  end
end
