class TermsPopup < BasePage

	# actions

	def wait_for_load
		@browser.wait_until { self.container.present? }
		self
	end

	def click_agree_button
		self.agree_button.click
		self
	end

	private # selectors

	def container
		@browser.div class: ['terms_dialog', 'GB_iframe_html']
	end

	def agree_button
		self.container.link class: 'ist_button'
	end

	self.printout self.public_instance_methods false
end
