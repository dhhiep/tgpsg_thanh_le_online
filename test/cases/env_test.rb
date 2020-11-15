require 'test_helper'

module TgpsgThanhLeOnline
  class EnvTest < TestCase

    it '.stage' do
      expect(Env.stage).must_equal('test')
    end

  end
end
