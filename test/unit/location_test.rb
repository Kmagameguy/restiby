# frozen_string_literal

require "test_helper"

module Restiby
  class LocationTest < MinitestSpec
    TEST_ROOT = File.expand_path("../../", __FILE__)

    before do
      @subject = ::Restiby::Location
      @name = "my_repo"
      @source = File.join(TEST_ROOT, "fixtures", "file.txt")
      @destinations = ["localstorage"]
      @forget = {
        keep_last: 20,
        keep_daily: 7,
        keep_weekly: 25,
        keep_monthly: 12,
        keep_yearly: 1
      }
      @properties = {}.tap do |hash|
        hash[:from]   = @source
        hash[:to]     = @destinations
        hash[:forget] = @forget
      end

      @location = @subject.new(name: @name, properties: @properties)
    end

    it "constructs a location object with a public interface" do
      assert_equal @name, @location.name
      assert_equal @source, @location.source
      assert_equal @destinations.sort.map(&:to_sym), @location.destinations.sort
      assert_equal "#{Restiby::Location::TAG_PREFIX}#{@name.to_s.downcase}", @location.tag
      assert_equal 20, @location.keep_last
      assert_equal 7,  @location.keep_daily
      assert_equal 25, @location.keep_weekly
      assert_equal 12, @location.keep_monthly
      assert_equal 1,  @location.keep_yearly
    end

    describe "#forget?" do
      it "is true if a forget policy is specified" do
        assert @location.forget?
      end

      it "is false if a forget policy is not specified" do
        location = @subject.new(name: @name, properties: @properties.except(:forget))
        
        refute location.forget?
      end
    end

    describe "#forget_and_prune_policy" do
      it "returns an empty hash if a forget policy is not specified" do
        location = @subject.new(name: @name, properties: @properties.except(:forget))

        assert_empty location.forget_and_prune_policy
      end

      it "specifies the prune option when a forget policy is specified" do
        assert_includes @location.forget_and_prune_policy.keys, :prune
      end
    end

    describe "#forget_policy" do
      it "returns the forget policy when specified" do
        assert_equal @forget, @location.forget_policy
      end

      it "only returns non-nil policy keys" do
        properties = {}.tap do |hash|
          hash[:from] = @source
          hash[:to]   = @destinations
          hash[:forget] = @forget.except(:keep_daily, :keep_monthly, :keep_yearly)
        end

        location = @subject.new(name: @name, properties: properties)

        assert_equal %i[keep_last keep_weekly], location.forget_policy.keys
      end
    end
  end
end
