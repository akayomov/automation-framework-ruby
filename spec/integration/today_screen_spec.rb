require_relative '../spec_helper'

suite 'Today\'s screen', :ui do
	before :all do
		DataGen.new(:user).register
		DataGen.mark :user, :suite

		on(LoginPage).open.login DataGen.use(:user)[:email], DataGen.use(:user)[:password]
		on(TermsPopup).wait_for_load.click_agree_button
	end

	test "allows to create a task" do
		task_description = Faker::Hacker.say_something_smart
		on(TodayPage) do |page|
			page.create_task task_description

			sleep 2, "System to take effect"

			expect(page.tasks_list).to include task_description
		end
	end

	test "allows to edit task" do
		update_task_description = Faker::Hacker.say_something_smart
		on(TodayPage) do |page|
			previous_task_description = page.tasks_list.last
			page.edit_task previous_task_description, update_task_description

			sleep 2, "System to take effect"

			expect(page.tasks_list).to include update_task_description
			expect(page.tasks_list).not_to include previous_task_description
		end
	end

	test "allows to mark task done" do
		on(TodayPage) do |page|
			task_description = page.tasks_list.last
			page.done_task task_description

			sleep 2, "System to take effect"

			expect(page.tasks_list).not_to include task_description
		end
	end
end
