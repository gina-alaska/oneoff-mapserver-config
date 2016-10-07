require "date"

MODIS_FORMAT = "%Y%m%d.%H%M"
NPP_FORMAT = "%y%j.%H%M"
TIME_FORMAT = "%Y.%m.%dT%H:%M"
default_junk = ["type raster","status on", "OFFSITE 0 0 0", "include \"projections/3338.include.map\""]


def get_date(fl)
	basename = File.basename(fl)

	if ( basename.include?("alaska_albers.tif") )
		#16_40_25_632_t1.20160829.2353_3_6_7.alaska_albers.tif
		date_part = basename.split("_")[4]
		return DateTime.strptime( date_part[3,45], MODIS_FORMAT)
	else
		#09_47_29_755_npp.16158.1632_DNB.tif 
		date_part = basename.split("_")[4]	
		#puts (date_part[4,2].to_i + 2000).to_s + "/" + date_part[6,3] +"/" +  date_part[10,2] + "/" + date_part[12,2]
                return DateTime.ordinal(date_part[4,2].to_i + 2000,  date_part[6,3].to_i, date_part[10,2].to_i, date_part[12,2].to_i, 0)
	end
end


def is_modis?(fl)
	return true if File.basename(fl).include?("alaska_albers.tif") 
	false
end

TYPE_MAPPER  = { "ATM1_500_ATM4_ATM3_ATM1" => "MODIS NC", 
	"7_2_1_500m_1" => "MODIS 721", 
	"2_6_1_500m_1" => "MODIS 621",
	"23" => "MODIS 23",
	"M05_M04_M03_I01" => "VIIRS NC",
	"I03_I02_I01" => "VIIRS 321",
	"DNB" => "VIIRS DNB",
	"I05" => "VIIRS THRM" }

def get_modis_type(name)
	return TYPE_MAPPER[name.split(".")[-3].split("_")[1,30].join("_")]
end

def get_viirs_type(name)
	return TYPE_MAPPER[name.split(".")[-2].split("_")[1,30].join("_")]
end

def nice_date(name)
	get_date(name).strftime(TIME_FORMAT)
end

def get_type(fl)
	basename = File.basename(fl)
        if (is_modis?(fl) )
                return get_modis_type(basename)
        else
                return get_viirs_type(basename)
        end
end


def get_name(fl) 
	basename = File.basename(fl)
	if (is_modis?(fl) )
		return get_modis_type(basename) + " " + nice_date(basename)
	else
		return get_viirs_type(basename) + " " + nice_date(basename)
	end
end

def layer_gen(path,name,group)
        layer_def = ["LAYER","\ttype raster","\tstatus on", "\tOFFSITE 0 0 0", "\tinclude \"projections/3338.include.map\""]
	layer_def << "\tname \"#{name}\""
	layer_def << "\tDATA \"#{path}\""
	layer_def << "\tGROUP \"#{group}\""
        layer_def << "\tMETADATA"
        layer_def << "\t\tWMS_TITLE \"#{name}\""
        layer_def << "\t\tWMS_ABSTRACT \"For #{File.basename(path)}\""
        #puts \t\t"wms_extent" "1525000.0 2752000.0 1605000.0 2792000.0"
        layer_def << "\tEND"
	layer_def << "END"

	layer_def
end


sorted = ARGV.sort{|x,y| get_date(x) <=> get_date(y) }

sorted.each do |item|
	puts "#{item} => #{get_name(item)}"
	#puts layer_gen(item,get_name(item),get_type(item)).join("\n")
	#puts layer_gen(item,get_name(item),nice_date(item).split("T")[0]).join("\n")
end


