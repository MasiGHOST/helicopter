//
//
//						   /---------\   
//						  / /---------\ 
//						 / /			
//						/ / Scripted
//						\ \	By:
//						 \ \
//						  \ \
//					     G.H.O.\=====|.T
//						    =====|\
//							 \ \
//						   	  \ \
//							   \ \
//							   / /
//						          / /
//						 /-------/ /
//						/---------/
//		
#include maps\mp\_utility;
#include code\utility;

init() {
	PreCacheModel("prop_suitcase_bomb");
	PreCacheModel( "projectile_cbu97_clusterbomb" );
	PreCacheShellShock("frag_grenade_mp");
	level.chopper_fx["explode"]["large"] = loadfx ("explosions/aerial_explosion_large");	
	level.chopper_fx["fire"]["trail"]["medium"] = loadfx ("smoke/smoke_trail_black_heli");	
	
}

heli() {
	self endon("exitReaper");
	self endon("disconnect");
	self endon("death");
	level.predatorInProgress = true;	
	//self.isGod = true;
	thread sound();
	self duffman\_common::setHealth(9999);
	self.inPredator = true;
	while(self GetCurrentWeapon() == "radar_mp" || self GetCurrentWeapon() == "none") wait .05;
	self.starwep = self GetCurrentWeapon();
	if(isDefined(self.reaper) && self.reaper) { self switchtoweapon(self.starwep); return; }
	self hide();	
	self.visible = false;
	self.reaper = true;
	self giveWeapon( "briefcase_bomb_mp" );
	self setWeaponAmmoStock( "briefcase_bomb_mp", 0 );
	self setWeaponAmmoClip( "briefcase_bomb_mp", 0 );
	for(i=0;i<6;i++) {
		self switchToWeapon( "briefcase_bomb_mp" );
		wait .5;
	}
	self.bs = newClientHudElem( self );
	self.bs.alpha = 0;
	self.bs.alignX = "left";
	self.bs.alignY = "top";	
	self.bs.horzAlign = "fullscreen";
	self.bs.vertAlign = "fullscreen";
	self.bs setShader("black", 640, 480);
	self.bs fadeovertime(.5);
	self.bs.alpha = 1;
	wait .5;
	angles = self getPlayerAngles();
	self takeweapon("briefcase_bomb_mp");
	self switchToWeapon( self.starwep );
	self disableWeapons();
	self.bs fadeovertime(.5);
	self.bs.alpha = 0;
	self.oldPos = self getOrigin();
	coord = strTok("21,0,2,24;-20,0,2,24;0,-11,40,2;0,11,40,2;0,-39,2,57;0,39,2,57;-48,0,57,2;49,0,57,2",";");
	for(k = 0; k < coord.size; k++) {
		tCoord = strTok(coord[k],",");
		self.r[k] = newClientHudElem(self);
		self.r[k].sort = 100;
		self.r[k].alpha = .8;
		self.r[k] setShader("white",int(tCoord[2]),int(tCoord[3]));
		self.r[k].x = int(tCoord[0]);
		self.r[k].y = int(tCoord[1]);
		self.r[k].hideWhenInMenu = true;
		self.r[k].alignX = "center";
		self.r[k].alignY = "middle";
		self.r[k].horzAlign = "center";
		self.r[k].vertAlign = "middle";
	}
	level.location = (0,0,1500);
	if(getDvar("mapname") == "mp_bloc") level.location = (1100,-5836,2500);
	else if(getDvar("mapname") == "mp_crossfire") level.location = (4566,-3162,2300);
	else if(getDvar("mapname") == "mp_citystreets") level.location = (4384,-469,2100);
	else if(getDvar("mapname") == "mp_creek") level.location = (-1595,6528,2500);
	else if(getDvar("mapname") == "mp_bog") level.location = (3767,1332,2300);
	else if(getDvar("mapname") == "mp_overgrown") level.location = (267,-2799,2600);	
	else if(getDvar("mapname") == "mp_nuketown") level.location = (84,-31,1800);
	else if(getDvar("mapname") == "mp_strike") level.location = (-100,-120,2170);	
	self setOrigin((level.location[0]+(300*cos(20)),level.location[1]+(300*sin(20)),level.location[2]));
	self setPlayerAngles((60,vectorToAngles(self.origin - level.location)[1],0));
	self playLocalSound("item_nightvision_on");
	self.bs destroy();		
		self setClientDvars("r_filmTweakDesaturation",1,"r_filmUseTweaks",1,"r_filmTweaksEnable",1,"r_filmTweakBrightness",.005,"cg_fovscale",1.2);
	p = getEntArray("player","classname");
	z=999999;
	for(i=0;i<p.size;i++) {
		if(isDefined(p[i]) && p[i].sessionstate == "playing" && p[i] != self && z > p[i].origin[2])
			z = p[i].origin[2];
	}
	if(z==999999) z = -100;
	vector = anglesToForward(self getPlayerAngles());
	level.forward = self getEye()+(vector[0]*70,vector[1]*70,vector[2]*70);
	self thread tate();
	
	//self thread bomb();
	
	fov = 1.2;
	hudElem = self.r;
	speed = 10;
	speedlimit = 0;	
	
	for(time = 0; time < 300; time++) {
		if(!self.reaper || !isDefined( self) || !isDefined(self.reaper))
			return;
		while(1)
		{
		wait 0.1;
		if(self AttackButtonPressed()) {
			self thread shoot();
				
		}
		
		if( self fragbuttonpressed() || self.health < 1 )
		{
		self thread killjet(self);
		}
		}
	}

	

	
}


tate() {
	self endon("disconnect");
	wait .05;
	i=randomint(360);
	offset = 900;
	centerposition = level.location;
	level.link = spawn("script_model",(centerposition[0]+(offset*cos(i)),centerposition[1]+(offset*sin(i)),centerposition[2]));
	level.link setModel("vehicle_mi24p_hind_desert");
	self setorigin(level.link.origin+(0,0,-200));
	self linkTo(level.link);
	level.link setcontents(1);
	
	while(1) {
		for(i=0;i<360;i+=.5) {
			location = (centerposition[0]+(offset*cos(i)),centerposition[1]+(offset*sin(i)),centerposition[2]);
			angles = vectorToAngles(location - level.link.origin);
			level.link moveTo(location,.5);
			level.link.angles = (angles[0],angles[1],angles[2]-10);
			wait .1;
		}
		i=0;
	}
}


bullet()
{
speed = 70;
		angles = self getPlayerAngles();
		if(angles[0] <= 30)
			self setPlayerAngles((30,angles[1],angles[2]));
		vector = anglesToForward(level.reap["bullet"].angles);
		forward = level.reap["bullet"].origin+(vector[0]*speed,vector[1]*speed,vector[2]*speed);
		collision = bulletTrace(level.reap["bullet"].origin,forward,false,self);
		level.reap["bullet"].angles = self getPlayerAngles();
		

			vector = anglesToForward(level.reap["bullet"].angles);
			level.reap["bullet"].origin = level.reap["bullet"].origin-(vector[0]*100,vector[1]*100,vector[2]*100);
			expPos = level.reap["bullet"].origin;
			playFx(level.chopper_fx["explode"]["large"],expPos);
			duffman\_common::TriggerEarthquake(3,1.6,expPos,450);

}

bomb()
{
self endon("death");
self endon("disconnect");
self endon("exitReaper");
for(;;)
{
self waittill ( "weapon_fired" );
vec = anglestoforward(self getPlayerAngles());
        end = (vec[0] * 200000, vec[1] * 200000, vec[2] * 200000);
        SPLOSIONlocation = BulletTrace( self gettagorigin("tag_eye"), self gettagorigin("tag_eye")+end, 0, self)[ "position" ];
		explode = loadfx( "explosions/tanker_explosion" );
        playfx(explode, SPLOSIONlocation);
        RadiusDamage( SPLOSIONlocation, 500, 700, 180, self );
        earthquake (0.3, 1, SPLOSIONlocation, 100);
		level.reap["bullet"] setModel("projectile_cbu97_clusterbomb");
			level.reap["bullet"].angles = self.angles;
			self playSound("weap_hind_missile_fire");
			level.reap["bullet"] moveto(SPLOSIONlocation,.15);
}

}
shoot()
{
			speed = 70;
level.reap["bullet"] = spawn("script_model",level.forward);
	//duffman\_common::TriggerEarthquake(2,0.1,self.origin,450);
	//level.reap["bullet"] setModel("projectile_cbu97_clusterbomb");
	level.bulletmodel = level.reap["bullet"];			
			level.reap["bullet"] setModel("projectile_cbu97_clusterbomb");
			level.reap["bullet"].angles = self.angles;
			self playSound("weap_hind_missile_fire");
			vec = anglestoforward(self getPlayerAngles());
        end = (vec[0] * 200000, vec[1] * 200000, vec[2] * 200000);
			SPLOSIONlocation = BulletTrace( self gettagorigin("tag_eye"), self gettagorigin("tag_eye")+end, 0, self)[ "position" ];
			level.reap["bullet"] moveto(SPLOSIONlocation,.15);
			
explode = loadfx( "explosions/tanker_explosion" );
        playfx(explode, SPLOSIONlocation);
        RadiusDamage( SPLOSIONlocation, 500, 700, 180, self );
        earthquake (0.3, 1, SPLOSIONlocation, 100);	
if(isDefined(level.bulletmodel)) level.bulletmodel delete();		
}

killjet(player)
{
self endon("exitReaper");
if(isDefined(player)) {
		player playLocalSound("item_nightvision_off");
		player unlink();
		player setOrigin(player.oldPos);
		if(isDefined(player.r[0])) for(k = 0; k < player.r.size; k++) if(isDefined(player.r[k])) player.r[k] destroy();
		player duffman\_common::setHealth(100);
		player.visible = true;
		player show();
		player.reaper = false;
		player.inPredator = false;
		player enableWeapons();
player setClientDvars("r_filmTweakDesaturation",.2,"r_filmUseTweaks",0,"r_filmTweaksEnable",1,"r_filmTweakBrightness",0,"cg_fovscale",1);		
player notify("exitReaper");
		}
}

sound()
{
self endon("exitReaper");
self endon("death");
self endon("disconnect");
		for(k = 0; k < level.players.size; k++) {
			if(isDefined(level.players[k]) && isAlive(level.players[k])) {
					if((level.teamBased && self.team == level.players[k].team))
						level.players[k] playlocalsound("crewTRVL");
			}
		}

}

		
