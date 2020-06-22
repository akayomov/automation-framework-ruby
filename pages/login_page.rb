class LoginPage < BasePage

	# actions

	def open
		@additional[:url] = '/users/showlogin'
		super
	end

	def login(email, password)
		self.email_field.set email
		self.password_field.set password
		self.login_button.click
		self
	end

	def wait_for_load
		@browser.wait_until do
			self.email_field.present? and
			self.password_field.present? and
			self.login_button.present?
		end
		self
	end

	private # selectors

	def email_field
		@browser.text_field name: 'email'
	end

	def password_field
		@browser.text_field name: 'password'
	end

	def login_button
		@browser.button class: 'submit_btn'
	end

	self.printout self.public_instance_methods false
end
