# This script install and configure all things to be able to run the automation on current node

case "$(lsb_release -is)" in
	"Ubuntu" )
		echo "Ubuntu OS detected. Processing with it"

		sudo apt install -y software-properties-common
		sudo apt-add-repository -y ppa:rael-gc/rvm
		sudo apt update
		sudo apt install rvm

		if ! grep -q 'source "/etc/profile.d/rvm.sh"' ~/.bashrc; then
			echo 'source "/etc/profile.d/rvm.sh"' >> ~/.bashrc
			source "/etc/profile.d/rvm.sh"
		fi
		;;
	* )
		echo "Unknown distribution. Installation won't be processed" &>2
		exit 1
		;;
esac


rvm install ruby --default
rvm use ruby
rvm ruby@default do gem install bundler
rvm ruby@default do bundle install

echo "--------------------------------------------------------------------------------"
echo "Ruby version: $(rvm ruby@default do ruby -v)"
echo "Gem version: $(rvm ruby@default do gem -v)"
echo "$(rvm ruby@default do bundle -v)"
echo "$(rvm ruby@default do bundle list)"

