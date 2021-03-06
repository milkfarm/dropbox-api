require "spec_helper"

describe Dropbox::API::File do

  before do
    @client = Dropbox::Spec.instance
    @filename = "#{Dropbox::Spec.test_dir}/spec-test-#{Time.now.to_i}.txt"
    @file = @client.upload @filename, "spec file"
  end

  after do
    # @file.delete
  end

  describe "#copy" do

    it "copies the file properly" do
      new_filename = @filename + ".copied"
      @file.copy new_filename
      @file.path.should == new_filename
    end

  end

  describe "#move" do

    it "moves the file properly" do
      new_filename = @filename + ".copied"
      @file.move new_filename
      @file.path.should == new_filename
    end

  end

  describe "#destroy" do

    it "destroys the file properly" do
      @file.destroy
      response = @client.raw.metadata(:path => @file.path, :include_deleted => true)
      response[".tag"].should == 'deleted'
    end

  end

  describe "#revisions" do

    it "retrieves all revisions as an Array of File objects" do
      @client.upload @file.path, "Updated content"

      revisions = @file.revisions
      revisions.size.should == 2
      revisions.collect { |f| f.class }.should == [Dropbox::API::File, Dropbox::API::File]
    end

  end

  describe "#restore" do

    it "restores the file to a specific revision" do
      old_rev = @file.rev

      @client.upload @file.path, "Updated content"

      file = @filename.split('/').last

      found = @client.find(@file.path)

      found.rev.should_not == old_rev

      newer_rev = found.rev

      @file.restore(old_rev)

      found = @client.find(@file.path)

      found.rev.should_not == old_rev
      found.rev.should_not == newer_rev

    end

  end

  # I don't think these tests matter because its checking of certain keys exist
  # but since the removal of Hashie, specifying the attributes is no explict.
  #describe "#share_url" do

  #  it "returns an Url object" do

  #    result = @file.share_url
  #    result.should be_an_instance_of(Dropbox::API::Object)
  #    result.keys.sort.should == ['.tag', 'client_modified', 'id', 'link_permissions', 'name', 'path_lower', 'rev', 'server_modified', 'size', 'url']

  #  end

  #end

  #describe "#copy_ref" do

  #  it "returns a copy_ref object" do

  #    result = @file.copy_ref
  #    result.should be_an_instance_of(Dropbox::API::Object)
  #    result.keys.sort.should == ['copy_reference', 'expires', 'metadata']

  #  end

  #end

  #describe "#direct_url" do

  #  it "returns an Url object" do

  #    result = @file.direct_url
  #    result.should be_an_instance_of(Dropbox::API::Object)
  #    result.keys.sort.should == ['link', 'metadata']

  #  end

  #end

  describe "#download" do

    it "should download the file" do
      @file.download.should == 'spec file'
    end

  end

end
