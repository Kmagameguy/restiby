# frozen_string_literal: true

require "test_helper"

module Restiby
  class BackendTest < ::Minitest::Test
    describe "Backend" do
      before do
        @name = "home"
        @type = "local"
        @path = "/home/user/backups"
        @passkey = "password1234"
        @locations = [Location.new(name: "Location 1", properties: { to: [@name] })]
        @exclude_file = ".restiby.exclude"
        @properties = {
          type: @type,
          path: @path,
          passkey: @passkey,
        }

        @backend = Backend.new(name: @name, properties: @properties, all_locations: @locations, exclude_file: @exclude_file)
      end

      it "constructs a backend object with a public interface" do
        assert_equal @name.to_sym, @backend.name
        assert_equal @type, @backend.type
        assert_equal @path, @backend.path
        assert_equal @passkey, @backend.passkey
        assert_equal @locations, @backend.locations
        assert_equal @exclude_file, @backend.exclude_file
      end

      it "only targets locations linked to the backend" do
        @locations << Location.new(name: "Location 2", properties: { to: [:different_backend] })
        backend = Backend.new(name: @name, properties: @properties, all_locations: @locations)

        assert_equal [@locations[0]], backend.locations
        assert_equal 1, backend.locations.count
        assert backend.locations.first.is_a?(Location)
      end
    end
  end
end