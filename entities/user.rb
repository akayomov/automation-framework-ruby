class UserEntity < Entity
	def initialize(object)
		super object
		self[:password] = Faker::Internet.password(min_length: 8) if self[:password].empty?
		self[:full_name] = Faker::Name.name if self[:full_name].empty?
		self[:email] = Faker::Internet.email(name: self[:full_name]) if self[:email].empty?
		logger.data "Gen: #{self[:full_name]} [#{self[:email]}]:#{self[:password]}"
	end

	def register(email: nil, password: nil, full_name:nil)
		self[:password] = password unless password.nil?
		self[:full_name] = full_name unless full_name.nil?
		self[:email] = email unless email.nil?

		post '/user/register', {
			email: self[:email],
			full_name: self[:full_name],
			password: self[:password]
		}
		if json_body[:error]
			raise json_body[:error]
		else
			logger.data "Reg: #{self[:full_name]} [#{self[:email]}]:#{self[:password]}"
			self.merge! json_body
		end
	end

	def delete
		post '/user/delete', {
			current_password: self[:password],
			token: self[:token]
		}
		if json_body[:success] == 'user deleted'
			logger.data "Deleted: #{self[:token]}"
		else
			logger.error "User wasn't deleted: #{self[:email]}|#{self[:password]}"
		end
	end

	def cleanup
		self.delete
	end
end
