class TodayPage < BasePage

	# actions

	def create_task(description)
		self.add_task_button.click
		@browser.wait_until { self.task_field.present? }
		self.task_field.send_keys description
		self.apply_add_button.click
		self
	end

	def edit_task(task, new_description)
		item = self.list_items.select {|el| el.div(class: 'task_content').text == task }.first
		item.button('aria-label': 'Edit').click
		@browser.wait_until { self.task_field.present? }
		self.task_field.send_keys [:control, 'a'], new_description
		self.apply_add_button.click
		self
	end

	def done_task(description)
		item = self.list_items.select {|el| el.div(class: 'task_content').text == description }.first
		item.button(class: 'item_checkbox').click
		self
	end

	def tasks_list
		self.list_items.map {|el| el.div(class: 'task_content').text }
	end

	private # selectors

	def add_task_button
		@browser.button class: 'plus_add_button'
	end

	def task_field
		@browser.div class: 'public-DraftEditor-content'
	end

	def apply_add_button
		@browser.button class: 'item_editor_submit'
	end

	def list_items
		@browser.lis class: 'task_list_item'
	end

	self.printout self.public_instance_methods false
end
