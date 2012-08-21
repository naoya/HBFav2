describe "ApplicationUser" do
  before do
    @user = ApplicationUser.new
    @user.hatena_id = "naoya"
    @user.password  = "password"
    @user.save
  end

  it "should have saved information" do
    @user.hatena_id.should == "naoya"
    @user.password.should  == "password"
  end

  it "should save hatena_id and password" do
    @user.hatena_id = "new_id"
    @user.password  = "new_password"
    @user.save

    @new_user = ApplicationUser.new
    @new_user.load
    @new_user.hatena_id.should == "new_id"
    @new_user.password.should  == "new_password"
  end
end
