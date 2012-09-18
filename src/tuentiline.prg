program tuentiline; // 8
global
  enemies=0;
  
  p_life;
  p_vel;
  p_damage;
  p_reload;
  
  numLevel;
  
  levelInfo[] =
    (  5, 0, 0, 0, 1, 1, 1, 1,
      10, 3, 0, 0, 1, 1, 1, 1,
      10, 5, 1, 0, 1, 1, 1, 1,
      11, 6, 1, 1, 1, 1, 1, 1,
      12, 7, 1, 1, 1, 1, 2, 1,
      13, 8, 2, 1, 1, 2, 3, 2,
      15,10, 2, 2, 2, 3, 4, 3,
      17,11, 3, 2, 3, 4, 5, 4,
      20,15, 3, 3, 4, 5, 5, 5,
       0, 0, 0, 0, 5, 5, 5, 5 );
      
  
local
  life;
  player;
  i;
begin
  text_size_x = 200;
  text_size_y = 200;

  set_mode(800,600,32,mode_window | mode_waitvsync);
  set_fps(48,0);
  load_fpg("tuentiline.fpg");
  i = load_music("music1.mp3", 1);
  play_music(i);
  menu();
end

process menu() // 10
begin
  let_me_alone();
  doTransition();
  put_screen(0,1);
  mouse.graph = 6;
          
  p_life = p_vel = p_damage = p_reload = 1;
          
  numLevel = 1;
          
  loop 
    if (key(_1)) 
      level();
    elseif (key(_2)) 
      instrucciones();
    elseif (key(_3)) 
      exit(0, "adios!"); 
    end 
    frame; 
  end
end

process Instrucciones() // 5
begin
  let_me_alone();
  doTransition();
  put_screen(0,25);
  loop
    if ( key(_esc) ) 
      menu(); 
    end
    frame;
  end
end

process Upgrade() // 17
begin

  let_me_alone();
  doTransition();
  
  stop_scroll(0);
  
  put_screen(0, 7);
  
  loop
    if ( key(_1) ) p_life++; level(); return; end
    if ( key(_2) ) p_vel++; level(); return; end
    if ( key(_3) ) p_damage++; level(); return; end
    if ( key(_4) ) p_reload++; level(); return; end
    frame;
  end
end

function doTransition() // 7
private
  tempGraph;
  screenGraph;
begin
  screenGraph = new_map(800,600); 
  get_screen(0, screenGraph);
  for (i = 0; i < 60; i++)
    tempGraph = new_map(800,10);
    map_block_copy(0, tempGraph, 0, 0, 0, screenGraph, 0, i*10, 800, 10);
    ScreenTransition(tempGraph, 400, i*10 + 5, abs(30-i), 0, 0, 300);
  end

  clear_screen();
  delete_text(all_text);
end

process ScreenTransition(graph, x, y, wait, ix, iy, life) // 6
begin
  z = -100000;
  while (wait-- > 0)
    frame;
  end
  while (life-- > 0)
    x += ix;
    y += iy;
    alpha-=8;
    frame;
  end  
end

process hud() // 4
begin
  graph=8;
  x = 0;
  y = 550;
  loop
    frame;
  end
end

process level() // 15
begin
  priority = 10;
  let_me_alone();
  doTransition();
  
  start_scroll(0, 0, 14, 0, 0, 3);
  
  prepareLevel(numLevel);
  

  write_int(0, 75, 575, txt_align_center, &p_life);
  write_int(0, 175, 575, txt_align_center, &p_vel);
  write_int(0, 275, 575, txt_align_center, &p_damage);
  write_int(0, 375, 575, txt_align_center, &p_reload);
  write_int(0, 775, 575, txt_align_center, &scroll[0].camera.life);
  
  if ( enemies < 1 )
    EndGame(10);
    return;
  end
  
  loop
    delete_draw(all_drawing);
    if ( enemies < 1 )
      numLevel++;
      upgrade();
    end
    frame;
  end
end

process teaser(num) // 6
private
  text;
  string str;
begin
  str = "Nivel " + itoa(num);
  text = write(0, 400, 100, txt_align_center, str );
  lock_text(text);
  set_text_size(text, 1000, 1000);
  
  from i = 1 to 100;
    frame;
  end
  delete_text(text);
end

process EndGame(backGraph) // 6
begin
  let_me_alone();
  doTransition();
  stop_scroll(0);
  put_screen(0,backGraph);
  repeat
    frame;
  until (scan_code==0 && !mouse.left && !mouse.right);
  repeat
    frame;
  until (scan_code!=0 || mouse.left || mouse.right);
  
  menu();
end

function prepareLevel(num) // 8
private 
  temp;
begin
  // Create player
  scroll[0].camera = entity(1000, 1000, 3, 1, 5*p_life*p_life, 0, 3, p_damage*p_damage);
  
  // Create hud
  hud();
  
  // Create teaser
  teaser(num);
  
  // Create enemies
  enemies = levelInfo[(num-1)*8]+levelInfo[(num-1)*8+1]+levelInfo[(num-1)*8+2]+levelInfo[(num-1)*8+3];
  
  for ( i = 0 ; i < levelInfo[(num-1)*8+0] ; i++ )
    createEnemy_Simple(rand(0, 2000), rand(0, 2000), levelInfo[(num-1)*8+4]);
  end
  for ( i = 0 ; i < levelInfo[(num-1)*8+1] ; i++ )
    createEnemy_Fast(rand(0, 2000), rand(0, 2000), levelInfo[(num-1)*8+5]);
  end
  for ( i = 0 ; i < levelInfo[(num-1)*8+2] ; i++ )
    createEnemy_Power(rand(0, 2000), rand(0, 2000), levelInfo[(num-1)*8+6]);
  end
  for ( i = 0 ; i < levelInfo[(num-1)*8+3] ; i++ )
    createEnemy_Firer(rand(0, 2000), rand(0, 2000), levelInfo[(num-1)*8+7]);
  end
end

function createEnemy_Simple(x, y, nlevel)
begin
  entity(x, y, 4, 0, nlevel, 2*nlevel, 2+3*nlevel, 1+nlevel/4);
end

function createEnemy_Fast(x, y, nlevel)
begin
  entity(x, y, 22, 0, nlevel, 2*nlevel, 5+5*nlevel, 1+nlevel/4);
end

function createEnemy_Power(x, y, nlevel)
begin
  entity(x, y, 24, 0, 3*nlevel, 5*nlevel, 2+nlevel, 4*nlevel);
end

function createEnemy_Firer(x, y, nlevel)
begin
  entity(x, y, 23, 0, 10*nlevel, 50+10*nlevel, 2+2*nlevel, 1+nlevel/4);
end



process entity(x, y, graph, player, life, firingChance, vl, damage) // 65
private
  il=0;
  ir=0;
  firing=0;
  firingAngle;
  reload=0;
  vl;
  aproxAngle = 50000;
  iniLife;
  miniX;
  miniY;
  dstAngle;
  sparse;
begin
  iniLife = life;
  resolution = 6;
  x *= resolution;
  y *= resolution;
  ctype = c_scroll;
  aproxAngle = rand(45,55) * 1000;
  aproxAngle *= (rand(0,1)*2)-1;
  sparse = rand(0,1);
  dstAngle = rand(0, 359) * 1000;
  
  from i = 1 to 100;
    frame; //10
  end
  
  loop
    if ( life < 1 )
      Explosion(x,y,50,2,4);
      alpha = 50;
      from i = 1 to 25;
        alpha -= 2;
        advance(il);
        frame;
      end
      if ( player )
        EndGame(9);
      else
        enemies--;
      end
      signal(id, s_kill);
      frame;
    end
    
    
  
    if ( player )
      il += ((key(_up) - key(_down)) * (3+(p_vel*p_vel/2)) 
            - (il*100/1000 + (abs(il)>0)*copysign(1,il) ) )
          + 0*(angle += ( ir += ((key(_left) - key(_right))*600) 
                                - ir*100/1000 )); // 20
      if ( mouse.left && reload < 1)
        firing = 1;
        reload = 1 + (50/((p_reload*p_reload)/2+1));
        firingAngle = fget_angle(x/resolution-scroll.x0,y/resolution-scroll.y0,mouse.x,mouse.y);
      else
        reload--;
      end
    else
      if ( rand(1, 10000) < 3 )
        sparse = !sparse;
      end
      if ( rand(1, 1000) < 3 )
        dstAngle = rand(0,359)*1000;
      end
    
      // Enemy IA
      if ( sparse )
        ir = near_angle(angle, dstAngle, 5000 ) - angle;
      else
        ir = near_angle(angle, get_angle(scroll[0].camera) + aproxAngle/(get_dist(scroll[0].camera)/(100*resolution)+1), 5000) - angle;
      end
      il = vl*3;
      if ( rand(0,1000) < firingChance && get_dist(scroll[0].camera) < 600*resolution )
        firing = 1; // 30
        firingAngle = get_angle(scroll[0].camera) + rand(-30000, 30000);
      end
      if ( rand(0,1000) < 30 )
        aproxAngle = -aproxAngle;
      end
    end
    
    angle += ir;
    advance(il);
    
    if ( overlap(type mouse) )
      draw(3, rgb(0,255,0), 196, 0, 
        x/resolution-scroll[0].x0 - 15, 
        y/resolution-scroll[0].y0 - 33, 
        x/resolution-scroll[0].x0 - 15 + (30*100*life/iniLife/100), 
        y/resolution-scroll[0].y0 - 33 + 5);
      if ( life < iniLife )
        draw(3, rgb(196,0,0), 196, 0, 
          x/resolution-scroll[0].x0 - 15 + (30*100*life/iniLife/100), 
          y/resolution-scroll[0].y0 - 33, 
          x/resolution-scroll[0].x0 - 15 + 30, 
          y/resolution-scroll[0].y0 - 33 + 5);
      end
    end
    
    if ( firing )
      bullet(x, y, firingAngle, 50+il/2, damage);
      firing = 0;
    end
    
    // Cyclic
    if ( player )
      if ( x/resolution > 2000 ) x -= 2000*resolution; end
      if ( x/resolution < 0 ) x += 2000*resolution; end // 40
      if ( y/resolution > 2000 ) y -= 2000*resolution; end
      if ( y/resolution < 0 ) y += 2000*resolution; end
      while ( (i = get_id(type entity)) )
        if ( x - i.x >  1000*resolution ) i.x += 2000*resolution; end
        if ( x - i.x < -1000*resolution ) i.x -= 2000*resolution; end
        if ( y - i.y >  1000*resolution ) i.y += 2000*resolution; end
        if ( y - i.y < -1000*resolution ) i.y -= 2000*resolution; end         
      end
      while ( (i = get_id(type bullet)) )
        if ( x - i.x >  1000*resolution ) i.x += 2000*resolution; end
        if ( x - i.x < -1000*resolution ) i.x -= 2000*resolution; end
        if ( y - i.y >  1000*resolution ) i.y += 2000*resolution; end
        if ( y - i.y < -1000*resolution ) i.y -= 2000*resolution; end // 50     
      end
      while ( (i = get_id(type Explosion)) )
        if ( x - i.x >  1000*resolution ) i.x += 2000*resolution; end
        if ( x - i.x < -1000*resolution ) i.x -= 2000*resolution; end
        if ( y - i.y >  1000*resolution ) i.y += 2000*resolution; end
        if ( y - i.y < -1000*resolution ) i.y -= 2000*resolution; end       
      end
      while ( (i = get_id(type Tail)) )
        if ( x - i.x >  1000*resolution ) i.x += 2000*resolution; end
        if ( x - i.x < -1000*resolution ) i.x -= 2000*resolution; end
        if ( y - i.y >  1000*resolution ) i.y += 2000*resolution; end
        if ( y - i.y < -1000*resolution ) i.y -= 2000*resolution; end       
      end
    end
    
    // Draw the marker in the minimap
    miniX = ((x/resolution mod 2000)*46/2000);
    miniY = ((y/resolution mod 2000)*46/2000); // 60
    while ( miniX < 0 ) miniX += 46; end
    while ( miniY < 0 ) miniY += 46; end
    if ( player )
      draw(5, rgb(0, 255, 0), 255, 0, 
        501 + miniX -1, 
        552 + miniY -1,
        501 + miniX +1, 
        552 + miniY +1);          
    else
      draw(5, rgb(255, 0, 0), 255, 0, 
        501 + miniX -1, 
        552 + miniY -1,
        501 + miniX +1, 
        552 + miniY +1); 
    end
    
    
    frame; // 65
  end
end

process bullet(x, y, angle, il, damage) // 20
private
  collisionId;
  ttl;
  tailRemaining;
  iniX, iniY;
begin
  graph = 5;
  ctype = c_scroll;
  ttl = 100;
  resolution = 6;
  tailRemaining = damage;
  iniX = x;
  iniY = y;
  size = 50;
  
  loop
    advance(il);
    while ((collisionId = collision(type entity)))
      if ( collisionId.player != father.player )
        Explosion(x,y,5,2,10); // 10
        collisionId.life -= damage;
        while ( (i = get_id(type Tail)) )
          if ( i.father == id )
            signal(i, s_kill);
          end
        end
        
        if ( collisionId.player )
          fade(100,25,25,64);
          frame;
          fade(100,100,100,16);
        end

        
        signal(id, s_kill);
        frame;
      end
    end
    if ( ttl-- < 1 )
      signal(id, s_kill_tree);
    end
    frame;
    if ( --tailRemaining > 0 )
      Tail(iniX, iniY, angle, il); // 20
    end
  end
end

process Tail(x, y, angle, il) // 6
begin
  graph = 5;
  ctype = c_scroll;
  resolution = 6;
  size = 25;
  
  loop
    advance(il);
    frame;
  end
end

process Explosion(x, y, size, is, da) // 7
begin
  graph = 11;
  resolution = 6;
  ctype = c_scroll;
  size = 50;
  
  while (alpha > 0)
    alpha-=da;
    size+=is;
    frame(25);
  end
end
