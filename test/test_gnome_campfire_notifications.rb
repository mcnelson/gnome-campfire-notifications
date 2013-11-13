require_relative 'helper'

describe GnomeCampfireNotifications do
  describe "#load_config" do
    it "loads correct values" do
      gcn = GnomeCampfireNotifications.new
      gcn.load_dummy_config({
        "token"     => 'foo',
        "roomid"    => 'bar',
        "room_name" => 'baz'
      })

      assert_equal 'foo', gcn.config["token"]
      assert_equal 'bar', gcn.config["roomid"]
      assert_equal 'baz', gcn.config["room_name"]
    end
  end

  describe "#send_notification" do
    it "returns true" do
      gcn = GnomeCampfireNotifications.new
      gcn.load_dummy_config
      input = {"user_id" => '1', "body" => 'hi'}

      gcn.stub(:get_username, 'Fred') do
        assert_equal true, gcn.send_notification(input)
      end
    end

    describe "quote escaping" do
      it "returns true" do
        gcn = GnomeCampfireNotifications.new
        gcn.load_dummy_config
        input = {"user_id" => '1', "body" => 'quote"s quote\'s'}

        gcn.stub(:get_username, 'Fred') do
          assert_equal true, gcn.send_notification(input)
        end
      end
    end

    describe "when self_user environment var is set" do
      it "doesn't notify and returns nil" do
        gcn = GnomeCampfireNotifications.new
        gcn.load_dummy_config("self_user" => 'Derp Herpinson')
        input = {"user_id" => '1', "body" => 'I should never be sent'}

        VCR.use_cassette('get_username') do
          assert_equal nil, gcn.send_notification(input)
        end
      end
    end

    describe "with self_user & self_only vars are set" do
      before do
        @gcn = GnomeCampfireNotifications.new
        @gcn.load_dummy_config(
          "self_user" => 'Derp Herpinson',
          "filter" => /Derp Herpinson/
        )
      end

      describe "message contains user name" do
        it "sends notification and returns true" do
          input = {"user_id" => '1', "body" => 'Derp Herpinson: yo wassup'}

          VCR.use_cassette('get_username_alt') do
            assert_equal true, gcn.send_notification(input)
          end
        end
      end

      describe "message doesn't contain user name" do
        it "doesn't notify and returns nil" do
          input = {"user_id" => '1', "body" => 'I should never be sent'}
          gcn = GnomeCampfireNotifications.new
          gcn.load_dummy_config

          VCR.use_cassette('get_username_alt') do
            assert_equal nil, gcn.send_notification(input)
          end
        end
      end
    end
  end

  describe "#get_username" do
    it "returns username in json hierarchy user -> name" do
      gcn = GnomeCampfireNotifications.new
      gcn.load_dummy_config

      VCR.use_cassette('get_username') do
        assert_equal "Derp Herpinson", gcn.get_username(1)
      end
    end

    it "returns unknown if ID is nil" do
      gcn = GnomeCampfireNotifications.new
      gcn.load_dummy_config
      assert_equal "Unknown", gcn.get_username(nil)
    end
  end
end
