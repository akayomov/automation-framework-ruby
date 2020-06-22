require_relative '../../../spec_helper'

suite 'API users/register', :api do
	test "without arguments produces proper error" do
		post '/user/register'

		expect_json 'error_tag', 'ARGUMENT_MISSING'
		expect_json 'error_code', 19
		expect_json 'http_code', 400
		expect_json 'error_extra.argument', 'email'
		expect_json 'error', 'Required argument is missing'
	end

	test "with email only" do
		post '/user/register', {email: Faker::Internet.email}

		expect_json 'error_tag', 'ARGUMENT_MISSING'
		expect_json 'error_code', 19
		expect_json 'http_code', 400
		expect_json 'error_extra.argument', 'full_name'
		expect_json 'error', 'Required argument is missing'
	end

	test "with invalid email" do
		post '/user/register', {email: 'invalid'}

		expect_json 'error_tag', 'INVALID_EMAIL'
		expect_json 'error_code', 8
		expect_json 'http_code', 400
		expect_json 'error_extra.expected', 'email'
		expect_json 'error_extra.argument', 'email'
		expect_json 'error', 'Email is invalid'
	end

	test "without password" do
		post '/user/register', {email: Faker::Internet.email, full_name: Faker::Name.name}

		expect_json 'error_tag', 'ARGUMENT_MISSING'
		expect_json 'error_code', 19
		expect_json 'http_code', 400
		expect_json 'error_extra.argument', 'password'
		expect_json 'error', 'Required argument is missing'
	end

	test "with short password" do
		post '/user/register', {email: Faker::Internet.email, full_name: Faker::Name.name, password: ''}

		expect_json 'error_tag', 'PASSWORD_TOO_SHORT'
		expect_json 'error_code', 4
		expect_json 'http_code', 400
		expect_json 'error', 'Password is too short'
	end
end
