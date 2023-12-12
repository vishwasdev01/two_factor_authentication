FactoryBot.define do
  factory :user do
    email { email }
    password { password }
    password_confirmation { password_confirmation }
    enable_2fa { false }
    otp { '123456' }
    # Add other attributes as needed

    trait :with_2fa do
      enable_2fa { true }
      otp { '123456' }
    end
  end
end