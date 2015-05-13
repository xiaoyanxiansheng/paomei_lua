local FighterAttr = class("FighterAttr");
function FighterAttr:ctor(atr)
	self.atk = atr.atk;
    self.def = atr.def;
    self.agi = atr.agi;
    self.hp = atr.hp;
    self.cd = atr.cd;
    
    getmetatable(self).__add = function(lhs,rhs)
		if instanceof(lhs,rhs) then
			self.atk = self.atk + rhs.atk;
			self.def = self.def + rhs.def;
			self.agi = self.agi + rhs.agi;
			self.hp = self.hp + rhs.hp;
			self.cd = self.cd + rhs.cd;
		end
		return self
	end

	getmetatable(self).__mul  = function(lhs,rhs)
		if instanceof(lhs,rhs) then
			self.atk = self.atk * rhs.atk;
			self.def = self.def * rhs.def;
			self.agi = self.agi * rhs.agi;
			self.hp = self.hp * rhs.hp;
			self.cd = self.cd + rhs.cd;
		end
		return self
	end

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