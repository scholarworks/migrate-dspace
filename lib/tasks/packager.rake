@attributes = {
	"mods:title" => "title",
	"mods:abstract" => "description"
}

namespace :packager do
 
   task :aip, [:file, :user_id] =>  [:environment] do |t, args|
	puts "loading task import"

		@source_file = args[:file] or raise "No source input file provided."
		@current_user = User.find_by_user_key(args[:user_id])
		
		puts "Building Impart Package from AIP Export file: " + @source_file
		
		@input_dir = File.dirname(@source_file)
		@output_dir = File.join(@input_dir, "unpacked") ## File.basename(@source_file,".zip"))
		Dir.mkdir @output_dir unless Dir.exist?(@output_dir)
		
		unzip_package(File.basename(@source_file))
				
#		Zip::File.open("/tmp/export/AIP.zip") do |zipfile|
#			zipfile.each do |f|
#				## puts f
#				fpath = File.join(@output_dir, f.name)
#				zipfile.extract(f,fpath) unless File.exist?(fpath)
#				process_mets(fpath)
#			end
#		end
		 
		# doc = Nokogiri::XML(open("/tmp/mets.xml"))
		# puts doc.at_xpath(".//mets//metsHdr")
   end
   
end

def unzip_package(zip_file)
	zpath = File.join(@input_dir, zip_file)
	file_dir = File.join(@output_dir, File.basename(zpath, ".zip"))
	Dir.mkdir file_dir unless Dir.exist?(file_dir)
	Zip::File.open(zpath) do |zipfile|
		zipfile.each do |f|
			fpath = File.join(file_dir, f.name)
			zipfile.extract(f,fpath) unless File.exist?(fpath)
		end
	end

	if File.exist?(File.join(file_dir, "mets.xml"))
		## puts "here"
		return process_mets(File.join(file_dir,"mets.xml"))
	else
		puts "No METS data found in package."
	end

end

def process_mets (mets_file)
	
	children = Array.new
	type = ""
	
	if File.exist?(mets_file)
		xml_data = Nokogiri::XML.Reader(open(mets_file))
		
		params = Hash.new {|h,k| h[k]=[]}
		
		xml_data.each do |node|
			## puts " ======> " + node.name + " - " + node.attributes
			
			if node.name == 'mets' && node.attribute("TYPE") == "DSpace COMMUNITY"
				puts "Converting community to collection..."
				type = "collection"
			end

			if node.name == 'mets' && node.attribute("TYPE") == "DSpace COLLECTION"
				puts " ==> Creating a collection..."
				type = "collection"
			end

			if node.name == 'mets' && node.attribute("TYPE") == "DSpace ITEM"
				puts " ====> Adding an item to a collection..."
				type = "item"
			end
			
			if @attributes.has_key? node.name 
				if node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
					## puts node.name + " => " + node.inner_xml
					params[@attributes[node.name]] << node.inner_xml					
				end
			end
			
			if node.name == 'mptr'
				if node.attribute('LOCTYPE') == 'URL'
					children.push(node.attribute('xlink:href'))
				end
			end
		end
		
		if type == 'collection'
			collection = createCollection(params)
			children.each do |child|
				childObject = unzip_package(child)
				collection.add_members(childObject.id)
				collection.save
			end
			return collection
		elsif type == 'item'
			item = createItem(params)
			return item
		end
	end
end

def createCollection (params, parent = nil)
	puts params
		coll = Collection.new(id: ActiveFedora::Noid::Service.new.mint)
		
		params["visibility"] = "open"
		

        coll.update(params)
        coll.apply_depositor_metadata(@current_user.user_key)
        coll.save

	return coll
end


def createItem (params, parent = nil)
	puts params
		item = GenericWork.new(id: ActiveFedora::Noid::Service.new.mint)
		
		params["visibility"] = "open"
		

        item.update(params)
        item.apply_depositor_metadata(@current_user.user_key)
        item.save

	return item
end
