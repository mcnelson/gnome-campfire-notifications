require_relative 'helper'

describe GnomeCampfireNotifications do
  describe "#send_notification" do
    it "returns true" do
      input = {user_id: '1', body: 'hi'}.to_json

      gcn = GnomeCampfireNotifications.new
      gcn.stub(:get_username, 'Fred') do
        assert_equal true, gcn.send_notification(input)
      end
    end

    describe "quote escaping" do
      it "returns true" do
        input = {user_id: '1', body: 'quote"s quote\'s'}.to_json

        gcn = GnomeCampfireNotifications.new
        gcn.stub(:get_username, 'Fred') do
          assert_equal true, gcn.send_notification(input)
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
