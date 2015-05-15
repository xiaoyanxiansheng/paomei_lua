local FighterAttr = class("FighterAttr");
function FighterAttr:ctor(atr)
	self.atk = atr.atk;
    self.def = atr.def;
    self.agi = atr.agi;
    self.hp = atr.hp;
    self.cd = atr.cd;

end

function FighterAttr:const()
	getmetatable(self).__newindex = nil
end

function FighterAttr:copy(attr)
	if instanceof(self,attr) then
		self.atk = attr.atk;
		self.def = attr.def;
		self.agi = attr.agi;
		self.hp = attr.hp;
		self.cd = atr.cd;
	end
end

return FighterAttr