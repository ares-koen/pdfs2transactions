require 'yaml'
app = {}
#================================================================================
def fnLoadApp(papp)
	cfg = YAML.load_file('config/config.yml')
	
	papp['bank'] = cfg['bank']
	papp['new_count'] = 0

	papp['dd'] = cfg['fs']['dd']
	papp['dd']['{bank}'] = papp['bank']

	papp['ddfl'] = cfg['fs']['fl']
	papp['ddfl']['{dd}'] = papp['dd']

	papp['ddpfl'] = cfg['fs']['pfl']
	papp['ddpfl']['{dd}'] = papp['dd']

	papp['ddptl'] = cfg['fs']['ptl']
	papp['ddptl']['{dd}'] = papp['dd']

	papp['ddtsv'] = cfg['fs']['tsv']
	papp['ddtsv']['{dd}'] = papp['dd']

	papp['rx_data'] = Regexp.new(cfg['parser']['data'])
	papp['rx_sd'] = Regexp.new(cfg['parser']['statementDate'])
	papp['rx_rs'] = Regexp.new(cfg['parser']['transaction'])
	papp['rx_fa'] = Regexp.new(cfg['parser']['tAmount'])
	papp['rx_fae'] = Regexp.new(cfg['parser']['tAmountEscape'])
	papp['rx_fas'] = Regexp.new(cfg['parser']['tAmountSign'])
	papp['fdmi'] = cfg['parser']['tdMonthIndx']
	papp['fddi'] = cfg['parser']['tdDayIndx']

	papp['pfl'] = (File.exists?(papp['ddpfl']) ? File.read(papp['ddpfl']) : "")
	papp['ptl'] = (File.exists?(papp['ddptl']) ? File.read(papp['ddptl']) : "")
	
	if not File.exists?(papp['ddtsv'])
		File.write(papp['ddtsv'],"Date\tDescription\tAmount\tFile\n")
	end
	
	papp['tsv'] = File.read(papp['ddtsv'])
end

def fnTrim(psv)
	psv = psv.gsub(/(\s{2,})/) { |m| m.gsub($1, " ") }
	psv = psv.gsub(/^(\s)/) { |m| m.gsub($1, "") }
	psv = psv.gsub(/(\s)$/) { |m| m.gsub($1, "") }
end

def fnGetStatementDate(papp,s)
	ta = s.scan(papp['rx_sd'])
	dy = ta[0][2]
	dd = ta[0][1]
	dm = ta[0][0]
	ma = dm.split(' ')
	dm = ma[ma.length - 1][0..2]
	syn = dy.to_i
	sdn = dd.to_i
	smn = (dm=="Jan"?1:((dm=="Feb"?2:((dm=="Mar"?3:((dm=="Apr"?4:((dm=="May"?5:((dm=="Jun"?6:((dm=="Jul"?7:((dm=="Aug"?8:((dm=="Sep"?9:((dm=="Oct"?10:((dm=="Nov"?11:((dm=="Dec"?12:0)))))))))))))))))))))))
	[syn,smn,sdn]
end

def fnParse(papp,pfs)
	p "Parsing: #{pfs}"
	if papp['pfl'][pfs]
		p "Info: already processed"
		return
	end
	papp['pfl'] += "#{pfs}\n"
	s = File.read(pfs)
	sda = fnGetStatementDate(papp,s)
	syn = sda[0]
	smn = sda[1]
	sdn = sda[2]
	sys = syn.to_s
	spys = (syn-1).to_s
	while true
		ta = s.split(papp['rx_data'])
		if ta.length == 0
			p "Info: no transactions found"
			break
		end
		ta.shift
		i = 0
		imax = ta.length
		while i < imax
			ts = ta[i]
			i += 1
			tta = ts.split(papp['rx_rs'])
			if tta.length < 4
				p "Error: invalid data (#{i})"
				next
			end
			tta.shift
			j = 0
			jmax = tta.length - 2
			while j < jmax
				tdm = tta[j + papp['fdmi']]
				tdd = tta[j + papp['fddi']]
				ts3 = tta[j + 2]
				j += 3
				tdm = ("0" + tdm)[/\d{2}$/]
				tdd = ("0" + tdd)[/\d{2}$/]
				tdy = (tdm.to_i > smn ? spys : sys).to_s
				t_date = "#{tdy}-#{tdm}-#{tdd}"
				tsa = ts3.split(papp['rx_fa'])
				ts = tsa[0]
				ts = ts.gsub(/(\n)/) { |m| m.gsub($1, " | ") }
				t_desc = fnTrim(ts)
				ts = tsa[1]
				ts = ts.gsub(papp['rx_fae']) { |m| m.gsub($1, "") }
				t_amount = fnTrim(ts)
				#asign = (t_desc[/(Withdraw|withdraw)/] ? "-" : (t_desc[/(Deposit|deposit)/] ? "" : "-"))
				asign = (t_desc[papp['rx_fas']] ? "" : "-")
				t = "#{t_date}\t#{t_desc}\t#{asign}#{t_amount}"
				if papp['ptl'][t]
					next
				end
				papp['new_count'] += 1
				papp['ptl'] += "#{t}\n"
				papp['tsv'] += "#{t}\t#{pfs}\n"
			end
		end
		break
	end
end

def fnRun(papp)
	fnLoadApp(papp)
	
	tf= papp['ddfl']
	if not File.exists?(tf)
		p "Error: file not found (#{tf})"
		exit
	end
	ds = File.read(tf)
	fd = ds.split("\n")
	i = 0
	imax = fd.length
	while i < imax
		fs = fnTrim(fd[i])
		i += 1
		if fs == "" or fs == " "
			next
		end
		fnParse(papp,fs)
	end
	File.write(papp['ddpfl'],papp['pfl'])
	File.write(papp['ddptl'],papp['ptl'])
	if papp['new_count'] > 0
		File.write(papp['ddtsv'],papp['tsv'])
	end
end
#================================================================================
fnRun(app)
