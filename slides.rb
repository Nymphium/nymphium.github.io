private def entry href, date, institute
	return {:href => href, :date => date,  :institute => institute}
end

def slides() 
	# エントリーを追加してね!
	return [
		entry("tsukubalua", "2017/02/12", "tsukuba.lua"),
		entry("tsukubapm3-luavm", "2016/05/14", "Tsukuba.pm #3"),
		entry("lonely_advent_calendar", "2015/12/02", "coins LT #11"),
		entry("luakatsu", "2015/04/15", "coins LT #10"),
		entry("geisen_yuri", "2014/07/16", "第1回芸専LT")
	]
end
