require 'yaml'
app = {}
#================================================================================
def fnLoadApp(papp)
	cfg = YAML.load_file('config/config.yml')
	
	papp['pdfbox'] = cfg['pdfbox']
	papp['bank'] = cfg['bank']

	papp['dd'] = cfg['fs']['dd']
	papp['dd']['{bank}'] = papp['bank']

	papp['ddpdf'] = cfg['fs']['pdf']
	papp['ddpdf']['{dd}'] = papp['dd']

	papp['ddtxt'] = cfg['fs']['txt']
	papp['ddtxt']['{dd}'] = papp['dd']

	papp['ddfl'] = cfg['fs']['fl']
	papp['ddfl']['{dd}'] = papp['dd']

	papp['fl'] = (File.exists?(papp['ddfl']) ? File.read(papp['ddfl']) : "")

	papp['epf'] = cfg['fs']['epf']
	papp['epf_java'] = cfg['fs']['epf_java']
	fnProcessEnvParameters(papp)
end

def fnProcessEnvParameters(papp)
	if not File.exists?(papp['epf'])
		p "Error: environment parameters file not found (#{papp['epf']})"
		exit
	end
	epf_java = ""
	s = File.read(papp['epf'])
	da = s.split(/\n/)
	for i in 0..da.length-1
		s = da[i]
		ta = s.split('=')
		if ta.length == 2 and ta[0] == papp['epf_java']
			epf_java = ta[1]
			break
		end
	end
	if epf_java == ""
		p "Error: environment parameter for java is missing or invalid"
		exit
	end
	papp['pdfbox'] = papp['pdfbox'].gsub(/(\{java\})/) { |m| m.gsub($1, epf_java) }
end

def fnProcessFile(papp,ppdf,ptxt)
	ret = ""
	if papp['fl'][ptxt]
		ret = "already processed"
	else
		papp['fl'] += "#{ptxt}\n"
		cmd = papp['pdfbox']
		#cmd['{pdf}'] = ppdf
		cmd = cmd.gsub(/(\{pdf\})/) { |m| m.gsub($1, ppdf) }
		#cmd['{txt}'] = ptxt
		cmd = cmd.gsub(/(\{txt\})/) { |m| m.gsub($1, ptxt) }
		r = system(cmd)
		ret = (r ? "success" : "failed")
	end
	ret
end

def fnProcessDir(papp,pddpdf,pddtxt)
	p "Dir: #{pddpdf}"
	p "--------------------------------------------"
	Dir.mkdir(pddtxt) unless Dir.exist?(pddtxt)
	da = Dir.entries(pddpdf)
	i = 0
	imax = da.length
	while i < imax
		ts = da[i]
		i += 1
		if ts == "." or ts == ".."
			next
		end
		tf = "#{pddpdf}/#{ts}"
		if File.directory?(tf)
			fnProcessDir(papp,tf,"#{pddtxt}/#{ts}")
		else
			p "File: #{tf}"
			ts = File.basename(tf, ".*")
			r = fnProcessFile(papp,tf,"#{pddtxt}/#{ts}.txt")
			p [ts,r]
		end
	end
end

def fnRun(papp)
	fnLoadApp(papp)
	
	ddpdf = "#{papp['ddpdf']}"
	ddtxt = "#{papp['ddtxt']}"
	
	if not File.directory?(ddpdf)
		p "Error: directory not found (#{ddpdf})"
		exit
	end
	
	fnProcessDir(papp,ddpdf,ddtxt)
	
	File.write(papp['ddfl'],papp['fl'])
end
#================================================================================
fnRun(app)
