require_relative 'helper'

describe GnomeCampfireNotifications do
  describe "#send_notification" do
    it "returns true" do
      input = {"user_id" => '1', "body" => 'hi'}

      gcn = GnomeCampfireNotifications.new
      gcn.stub(:get_username, 'Fred') do
        assert_equal true, gcn.send_notification(input)
      end
    end

    describe "quote escaping" do
      it "returns true" do
        input = {"user_id" => '1', "body" => 'quote"s quote\'s'}

        gcn = GnomeCampfireNotifications.new
        gcn.stub(:get_username, 'Fred') do
          assert_equal true, gcn.send_notification(input)
        end
      end
    end

    describe "when self_user environment var is set" do
      it "doesn't notify and returns nil" do
        ENV['GNOME_CAMPFIRE_NOTIFICATIONS_SELF_USER'] = 'Derp Herpinson'
        input = {"user_id" => '1', "body" => 'I should never be sent'}

        VCR.use_cassette('get_username') do
          gcn = GnomeCampfireNotifications.new
          assert_equal nil, gcn.send_notification(input)
        end
      end
    end

    describe "with self_user & self_only vars are set" do
      before do
        ENV['GNOME_CAMPFIRE_NOTIFICATIONS_SELF_USER'] = 'Derp Herpinson'
        ENV['GNOME_CAMPFIRE_NOTIFICATIONS_SELF_ONLY'] = 'true'
      end

      describe "message contains user name" do
        it "sends notification and returns true" do
          input = {"user_id" => '1', "body" => 'Derp Herpinson: yo wassup'}

          VCR.use_cassette('get_username_alt') do
            gcn = GnomeCampfireNotifications.new
            assert_equal true, gcn.send_notification(input)
          end
        end
      end

      describe "message doesn't contain user name" do
        it "doesn't notify and returns nil" do
          input = {"user_id" => '1', "body" => 'I should never be sent'}

          VCR.use_cassette('get_username_alt') do
            gcn = GnomeCampfireNotifications.new
            assert_equal nil, gcn.send_notification(input)
          end
        end
      end
    end
  end

  describe "#get_username" do
    it "returns username in json hierarchy user -> name" do
      VCR.use_cassette('get_username') do
        gcn = GnomeCampfireNotifications.new
        assert_equal "Derp Herpinson", gcn.get_username(1)
      end
    end

    it "returns unknown if ID is nil" do
      gcn = GnomeCampfireNotifications.new
      assert_equal "Unknown", gcn.get_username(nil)
    end
  end
end
