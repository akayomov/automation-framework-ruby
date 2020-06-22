# Ruby Automation Framework

An example and boilerplate for Automation Framework based on Ruby (not RoR).
In mostly cases I'll be using this skeleton for building automation...

#### Example
An example shows a partial testing of todoist.com application. There are two specs implemented to display posibilities:
- integration - a small testing that covers CRUD tasks on 'Today' page, also can be mentioned as e2e test (simplification is made due to absent knowledge of projects info)
- system API - a test for /user/register endpoint (happy path excluded) represents posibilities of API testing

## Specifications
- __Ruby__ - latest version of Ruby used as a programming language base.
- __RSpec__ - unit tests framework used as a tests runner.
- __Watir__ - Selenium wrapper which gives cross-browser and elements access simplification.
- __Airborne__ - library for simplification API testing, gives simplification to making requests and additional RSpec matchers for testing responces.
- __Faker__ - a library that generates unique predefined testdata.
- __Logging__ - a library that provides an extended log outputting that can be mastered to STDOUT, file, or external integrations.
- __DotEnv__ - a library that manages configutation for whole framework, it provides system Environment Variables into a framework and simplifies management on CI.

## Custom Implementations
### Page Object Model
Implementation stored in ```./tools/page_object_model.rb file.```

It contains ```BasePage``` class, which holds basic needed methods and implementations. Extended classes may be dealing with ```@browser``` for accesing selenium elements. Details on [Watir website](http://watir.com/guides/locating/).

For holding additional parameters for page there is an ```@additional``` object, For example ```@additional[:url]``` could be used to store an addition to base url for opening specific page via ```#open``` method.

PageObject implementation should be a class:
- stored in ```./pages/\*\*/\*.rb``` file
- extended from ```BasePage```
- implement private methods as selectors
- implement public methods as actions

Also ```self.printout self.public_instance_methods false``` at the end of the class implementation will automatically do a printout to log output for all public methods (actions) within the POM class.

There is also kind a ```ClassFactory``` implementation for RSpec which allows to use method ```on``` instead of holding class instances for POM. There are 2 usages of it:
- ```on(PageClass).action``` - for single or chained actions
- ```on PageClass { |page| page.action }``` - blocked for multiple actions

### DataGen
I prefer testdata to be automatically generated, this gives an extra multiplication to the executions and some random for coverage.
Simple single string data is generated via ```Faker``` gem, it's automatically synchronized with RSpec seed. You can reproduce data with providing seed in ```./specs/spec_helper.rb``` (password may still be unique and not repeated). Whole implementation in stored in ```./tools/datagen.rb```

Also it implements entities which is a stored testdata objects integrated with a product. So DataGen allows to produce testdata through the API, use them for tests and cleanup at the end of execution.

Entity is a Hash extended class that produces an API posibilities:
- stored in ```./entities/[type].rb```
- class named ```[Type]Entity``` and extended from ```Entity``` class
- may use ```Airborne``` and ```Faker``` for implementing posibilities
- must implement ```#cleanup``` method (for post-conditions cleanup)

```DataGen``` itself can be used within the tests, and implements:
- ```#new``` will generate NEW item for entity (use separate method to save it to product)
- ```#use``` will return last generated entity, to use it within further actions in test
- ```#mark(type, context, entity)``` - will mark for post-execution cleanup where: - type is a symbol name of entity ```:type```, - context is one of :test, :suite which means it will be cleaned up after test or suite respectively, - entity is a specific entity or latest created for type is not specified.

### Output and tools
This framework is working upon logging gem. That's why there is deprecated ```puts``` method, and logger.[level] might be used instead. Whole logger is being implemented as monkey-patching Kernel module and stored in ```./tools/logger.rb```

```debug``` method allows to inspect internal data during execution. It allows to use multiple variables via comma.

```logger.[level]``` outputs a message on specific level message. By default gem implements folloding levels, and they are used for proper messages respectively: 
- ```api_d``` - API Data, requests and responses details
- ```api``` - API, generic info for requests and responses
- ```pom``` - PageObjectModel, actions executed
- ```debug``` - Debug, custom messages
- ```data``` - TestData, entities posibilities executions
- ```runner``` - Runner, RSpec config and examples data and statuses
- ```warn``` - Warning, something that may affect tests execution
- ```error``` - Error, failure that will definitelly fail further execution

```sleep(duration, reason)``` wrapps generic Kernel method. There is a meaning that using sleeps is a bad practice. For now it will produce a warning message for sleeps without a reasons. The best case is to use ```@browser.wait_until``` instead of sleeping.

```breakpoint``` can be used for development and debugging the tests. It's being maintained via ```AVOID_BREAKPOINTS``` env variable. It's being set to ```true``` on CI which will produce an error output instead of stopping execution.

# Installation and execution
Framework is being implemented and used within \*unix system.
Defaulty it's managed to be working under debian(Ubuntu) and rhel(Fedora) systems, but can be runned everywhere where Ruby is working.

## Installation
Supported and tested OSes:
- Ubuntu

For supported systems there is a script which automatically installs all requirements. Just call ```./install.sh``` (it will install rvm and use it for execution)

On other systems install latest version of Ruby(+gem), then install Bundler via ```gem install bundler``` (maybe with ```sudo```), and then do ```bundle install```

## Running
For supported systems: ```./run.sh```, then can be used arguments like ```--tag``` or path for spec files.

Others just use ```bundle exec rspec``` with needed arguments.

## Results
Execution produces detailed STDOUT with specific format.

Also due to connected junit formatter execution produces an XML file to ```./results/``` directory

Additionally each failed UI example produce a screenshot to ```./results/screenshots/``` directory

# Structure
- __./entities/\*\*/\*.rb__ - DataGen testdata entities classes.
- __./pages/\*\*/\*.rb__ - POM PageObjects classes.
- __./results/__ - a folder with execution results.
- __./spec/\*\*/\*_spec.rb__ - a folder with tests itselves.
- __./spec/spec_helper.rb__ - a helper file which stores generic RSpec config which requires to each test file.
- __./tools/__ - a directory for wrappers and helpers used within framework.
- __./tools/api_wrapper.rb__ - Patch for Airborne gem which porduces proper output.
- __./tools/configuration_parser.rb__ - DotEnv implementation.
- __./tools/datagen.rb__ - implementation of DataGen, described earlier.
- __./tools/logger.rb__ - Kernel monkey-patch for implementing Logging gem.
- __./tools/output_formatter.rb__ - an RSpec Formatter which implements custom output for examples execution to Logging.
- __./tools/page_object_model.rb - an implementation of ```BasePage``` and ```ClassFactory``` for POM.
- __.gitignore__ - generic ignoring for git.
- __.ci.env__ - default config for CI
- __Gemfile__ - a file with gem dependencies
- __install.sh__ - framework installation script
- __README.md__ - this file
- __run.sh__ - framework running script
