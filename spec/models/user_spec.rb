require 'rails_helper'

RSpec.describe User, type: :model do
  it "名前、メールアドレス、パスワードがあれば有効である" do
    user = User.new(
      name: "テスト",
      email: "test@example.com",
      password: "password",
      encrypted_password: "securepass"
    )
    expect(user).to be_valid
  end
end
