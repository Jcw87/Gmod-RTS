DeriveGamemode( "fretta" )
IncludePlayerClasses()	

GM.Name 	= "RTS"
GM.Author 	= "Jcw87"
GM.Email 	= ""
GM.Website 	= ""
GM.Help		= "No Help Available"

GM.TeamBased = true					// Team based game or a Free For All game?
GM.AllowAutoTeam = true				// Allow auto-assign?
GM.AllowSpectating = true			// Allow people to spectate during the game?
GM.SecondsBetweenTeamSwitches = 10	// The minimum time between each team change?
GM.GameLength = 60					// The overall length of the game
GM.RoundLimit = -1					// Maximum amount of rounds to be played in round based games
GM.VotingDelay = 5					// Delay between end of game, and vote. if you want to display any extra screens before the vote pops up

GM.NoPlayerSuicide = false			// Set to true if players should not be allowed to commit suicide.
GM.NoPlayerDamage = false			// Set to true if players should not be able to damage each other.
GM.NoPlayerSelfDamage = false		// Allow players to hurt themselves?
GM.NoPlayerTeamDamage = true		// Allow team-members to hurt each other?
GM.NoPlayerPlayerDamage = false 	// Allow players to hurt each other?
GM.NoNonPlayerPlayerDamage = false 	// Allow damage from non players (physics, fire etc)
GM.NoPlayerFootsteps = false		// When true, all players have silent footsteps
GM.PlayerCanNoClip = false			// When true, players can use noclip without sv_cheats
GM.TakeFragOnSuicide = false		// -1 frag on suicide

GM.MaximumDeathLength = 0			// Player will respawn if death length > this (can be 0 to disable)
GM.MinimumDeathLength = 4			// Player has to be dead for at least this long
GM.AutomaticTeamBalance = false     // Teams will be periodically balanced 
GM.ForceJoinBalancedTeams = true	// Players won't be allowed to join a team if it has more players than another team
GM.RealisticFallDamage = false		// Set to true if you want realistic fall damage instead of the fix 10 damage.
GM.AddFragsToTeamScore = false		// Adds player's individual kills to team score (must be team based)

GM.NoAutomaticSpawning = false		// Players don't spawn automatically when they die, some other system spawns them
GM.RoundBased = false				// Round based, like CS
GM.RoundLength = 30					// Round length, in seconds
GM.RoundPreStartTime = 5			// Preperation time before a round starts
GM.RoundPostLength = 8				// Seconds to show the 'x team won!' screen at the end of a round
GM.RoundEndsWhenOneTeamAlive = true	// CS Style rules

GM.EnableFreezeCam = true			// TF2 Style Freezecam
GM.DeathLingerTime = 4				// The time between you dying and it going into spectator mode, 0 disables

GM.SelectModel = false				// Can players use the playermodel picker in the F1 menu?
GM.SelectColor = false				// Can players modify the colour of their name? (ie.. no teams)

GM.PlayerRingSize = 48				// How big are the colored rings under the player's feet (if they are enabled) ?
GM.HudSkin = "SimpleSkin"			// The Derma skin to use for the HUD components
GM.SuicideString = "died"			// The string to append to the player's name when they commit suicide.
GM.DeathNoticeDefaultColor = Color( 255, 128, 0 ); // Default colour for entity kills
GM.DeathNoticeTextColor = color_white; // colour for text ie. "died", "killed"

GM.ValidSpectatorModes = { OBS_MODE_CHASE, OBS_MODE_IN_EYE, OBS_MODE_ROAMING } // The spectator modes that are allowed
GM.ValidSpectatorEntities = { "player" }	// Entities we can spectate, players being the obvious default choice.
GM.CanOnlySpectateOwnTeam = true; // you can only spectate players on your own team

TEAM_BLUE = 1
TEAM_RED = 2
TEAM_YELLOW = 3
TEAM_GREEN = 4

TEAM_BLUE_MASK = 1 << 0
TEAM_RED_MASK = 1 << 1
TEAM_YELLOW_MASK = 1 << 2
TEAM_GREEN_MASK = 1 << 3

color_blue = Color( 0, 0, 255 )
color_red = Color( 255, 0, 0 )
color_yellow = Color( 255, 255, 0 )
color_green = Color( 0, 255, 0 )
color_grey = Color(200, 200, 200)

include("minimap.lua")
include("spawnpoints.lua")
include("entity_extension.lua")
include("player_extension.lua")

local TeamClasses = {"Engineer"}

function GM:CreateTeams()
	if !GAMEMODE.TeamMask then GAMEMODE.TeamMask = TEAM_BLUE_MASK | TEAM_RED_MASK | TEAM_YELLOW_MASK | TEAM_GREEN_MASK end
	local teams = team.GetAllTeams()
	for k, v in pairs(teams) do
		if k > TEAM_CONNECTING && k < TEAM_UNASSIGNED then teams[k] = nil end
	end
	if GAMEMODE.TeamMask & TEAM_BLUE_MASK > 0 then
		team.SetUp( TEAM_BLUE, "Blue Team", color_blue, true )
		team.SetClass( TEAM_BLUE, TeamClasses)
	end
	if GAMEMODE.TeamMask & TEAM_RED_MASK > 0 then
		team.SetUp( TEAM_RED, "Red Team", color_red, true )
		team.SetClass( TEAM_RED, TeamClasses )
	end
	if GAMEMODE.TeamMask & TEAM_YELLOW_MASK > 0 then
		team.SetUp( TEAM_YELLOW, "Yellow Team", color_yellow, true )
		team.SetClass( TEAM_YELLOW, TeamClasses )
	end
	if GAMEMODE.TeamMask & TEAM_GREEN_MASK > 0 then
		team.SetUp( TEAM_GREEN, "Green Team", color_green, true )
		team.SetClass( TEAM_GREEN, TeamClasses )
	end
	team.SetUp( TEAM_CONNECTING, "Joining/Connecting", color_grey, false )
	team.SetUp( TEAM_UNASSIGNED, "Unassigned", color_grey, false )
	team.SetUp( TEAM_SPECTATOR, "Spectators", color_grey, true )
	team.SetSpawnPoint( TEAM_SPECTATOR, "info_player_start" )
	team.SetClass( TEAM_SPECTATOR, { "Spectator" } )
end

function GM:Initialize()
	self.BaseClass:Initialize()
	minimap.LoadEmpiresScript()
	GAMEMODE:RegisterBuilding("rts_refinery", "models/imperial/buildings/refinery/imp_refinery.mdl", "Refinery", 100)
	GAMEMODE:RegisterBuilding("rts_barracks", "models/imperial/buildings/barracks/imp_barracks.mdl", "Barracks", 200)
	GAMEMODE:RegisterBuilding("rts_vehiclefactory", "models/imperial/buildings/vehiclefactory/imp_vehiclefactory.mdl", "Vehicle Factory", 400)
end

function GM:CanPlaceBuilding(ID, Pos, Ang)
	-- Check for obstructions
	local tpos = Pos + Vector(0, 0, 16)
	local t = {mask = MASK_PLAYERSOLID}
	t.start = tpos
	t.endpos = tpos
	t.mins = Vector(-128. -128, 0)
	t.maxs = Vector(128, 128, 128)
	local tr = util.TraceHull(t)
	if tr.Hit then return false end

	-- Check to make sure it isn't hanging off a cliff or in the air
	t.mask = CONTENTS_SOLID
	local rot = Angle(0, Ang, 0)
	local locs = {}
	locs[1] = tpos
	local v
	v = Vector(-128, -128, 0)
	v:Rotate(rot)
	locs[2] = tpos + v
	v = Vector(128, -128, 0)
	v:Rotate(rot)
	locs[3] = tpos + v
	v = Vector(128, 128, 0)
	v:Rotate(rot)
	locs[4] = tpos + v
	v = Vector(-128, 128, 0)
	v:Rotate(rot)
	locs[5] = tpos + v
	for i=1,5 do
		tpos = locs[i]
		t.start = tpos
		t.endpos = tpos + Vector(0, 0, -32)
		tr = util.TraceLine(t)
		if !tr.HitWorld || tr.HitSky || tr.HitNoDraw then return false end
	end
	return true
end

local Buildings = {}

function GM:RegisterBuilding(class, model, name, cost)
	local new = {class = class, model = model, name = name, cost = cost}
	table.insert(Buildings, new)
end

function GM:GetBuildings()
	return Buildings
end

