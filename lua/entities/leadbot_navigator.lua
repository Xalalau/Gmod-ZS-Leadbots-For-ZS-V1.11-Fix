if SERVER then AddCSLuaFile() end

ENT.Base = "base_nextbot"
ENT.Type = "nextbot"

function ENT:Initialize()
	if CLIENT then return end

	self:SetModel("models/player.mdl")
	self:SetNoDraw(!GetConVar("developer"):GetBool())
	self:SetSolid(SOLID_NONE)

	self.PosGen = nil
	self.NextJump = -1
	self.NextDuck = 0
	self.cur_segment = 2
	self.Target = nil
	self.LastSegmented = 0
	self.ForgetTarget = 0
	self.NextCenter = 0
	self.LookAt = Angle(0, 0, 0)
	self.LookAtTime = 0
	self.goalPos = Vector(0, 0, 0)
	self.strafeAngle = 0
	self.nextStuckJump = 0

	if LeadBot.AddControllerOverride then
		LeadBot.AddControllerOverride(self)
	end
end

function ENT:ChasePos()
	self.P = Path("Follow")
	self.P:SetMinLookAheadDistance(10)
	self.P:SetGoalTolerance(20)
	self.P:Compute(self, self.PosGen)

	if !self.P:IsValid() then return end

	while ( self.P:IsValid() and self.PosGen ) do
		self.P:Compute(self, self.PosGen, function( area, fromArea, ladder, elevator, length )
			if ( !IsValid( fromArea ) ) then

				-- first area in path, no cost
				return 0
			
			else
			
				if ( !self.loco:IsAreaTraversable( area ) ) then
					-- our locomotor says we can't move here
					return -1
				end

				-- compute distance traveled along path so far
				local dist = 0

				if ( IsValid( ladder ) ) then
					dist = ladder:GetLength()
				elseif ( length > 0 ) then
					-- optimization to avoid recomputing length
					dist = length
				else
					dist = ( area:GetCenter() - fromArea:GetCenter() ):GetLength()
				end

				local cost = dist + fromArea:GetCostSoFar()

				-- check height change
				local deltaZ = fromArea:ComputeAdjacentConnectionHeightChange( area )
				if ( deltaZ >= self.loco:GetStepHeight() ) then
					if ( deltaZ >= self.loco:GetMaxJumpHeight() ) then
						-- too high to reach
						return -1
					end

					-- jumping is slower than flat ground
					local jumpPenalty = 5
					cost = cost + jumpPenalty * dist
				elseif ( deltaZ < -self.loco:GetDeathDropHeight() ) then
					-- too far to drop
					return -1
				end

				return cost
			end
		end )
		self.cur_segment = 2

		coroutine.wait(1)
		coroutine.yield()
	end
end

function ENT:OnInjured()
	return false
end

function ENT:OnKilled()
	return false
end

function ENT:IsNPC()
	return false
end

function ENT:Health()
	return nil
end

function ENT:RunBehaviour()
	while (true) do
		if self.PosGen then
			self:ChasePos({})
		end

		coroutine.yield()
	end
end