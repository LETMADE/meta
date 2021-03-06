require 'spec_helper'

describe Discussion do
  let(:owner) { User.make! }
  let(:product) { Product.make! }
  let(:discussion) { Discussion.make!(user: owner, product: product) }
  let(:closer) { User.make! }

  let(:core_member) { User.make!(is_staff: true) }

  describe '#tags' do
    before { discussion.tag_list = 'bug,code' }

    it { discussion.tags.map(&:name).should =~ ['bug', 'code'] }
    it { product.discussions.tagged_with('bug').size.should == 1 }
  end
end
