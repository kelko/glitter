		#a class for creating the "about"-data of the program
		#follows the singleton-pattern (->GoF, Design Patterns)
		class About
			#the known licenses
				LICENCE_GPL = "GNU General Public Licence"
				LICENCE_LGPL = "GNU Lesser/Library General Public Licence"
				LICENCE_BSD = "BSD-Licence"
				LICENCE_CC = "Creative-Common Licence"
				LICENCE_CC_BY_NC = "Creative-Common Licence BY NC (Non-Commercial)"
				LICENSE_CC_BY_NC_ND = "Creative-Common Licence BY NC ND (Non-Commercial, Non-Derivate)"
				LICENSE_CC_BY_NC_SA = "Creative-Common Licence BY NC SA (Non-Commercial, Share Alike)"
				LICENCE_PD = "Public Domain"
				LICENCE_OWN = "Own licence, see COPYRIGHT.txt"
				
				KEY_NAME = "name"
				KEY_DESC = "desc"
				KEY_AUTHOR = "author"
				KEY_MAIL = "mail"
				KEY_VERSION = "version"
				KEY_LICENSE = "license"

			private
				@@instance = nil
				
				#the constructor
				def initialize
					#default-informations
					#of cause mine ;-)
					@about = {'name'=>nil,'desc'=>nil, 'author'=>":kelko:",'mail'=>"kelko@anakrino.de",'version'=>0.1,'licence'=>About::LICENCE_GPL}
				end	
		
			public
				
				#-> singleton-pattern
				def About.getInstance
					@@instance = About.new unless @@instance
					@@instance
				end
		
				#get the information "key"
				#one of the KEY_ constants can be used
				def get(key)
					@about[key]
				end
		
				#set the information "key" to the value "val"
				def set(key,val)
					@about[key] = val
					self
				end
				
				#prints out the about-data
				def to_s
					msg = "About "
					msg += "#{@about['name']}" if @about['name']
					msg += "#{$0}" unless @about['name']
					msg += ":\n\tDescription:\t#{@about['desc']}" if @about['desc']
					msg += "\n\tAuthor:\t\t#{@about['author']} (#{@about['mail']})\n\tVersion:\t#{@about['version']}\n\tLicence:\t#{@about['licence']}\n"
					
				end
		
				#imports a about-hashtable
				#does not check anything
				def <<(newAbout)
					@about = newAbout
					newAbout
				end
		
				#returns the information as array
				def to_a
					output = [
						@about['name'],
						@about['desc'],
						@about['author'],
						@about['mail'],
						@about['version'],
						@about['licence']
					]
					output
				end
		
				#returns the hashtable
				def to_h
					@about
				end
		
		end