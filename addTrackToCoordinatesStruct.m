k = 14; % position where we want to add a new track

coordinates.x_3chemotaxis_Cytoplasts.original_x=...
[coordinates.x_3chemotaxis_Cytoplasts.original_x{1:k-1},{x},...
coordinates.x_3chemotaxis_Cytoplasts.original_x{k:end}];

coordinates.x_3chemotaxis_Cytoplasts.original_y=...
[coordinates.x_3chemotaxis_Cytoplasts.original_y{1:k-1},{y},...
coordinates.x_3chemotaxis_Cytoplasts.original_y{k:end}];

x_centered=x-x(1);

coordinates.x_3chemotaxis_Cytoplasts.centered_x=...
[coordinates.x_3chemotaxis_Cytoplasts.centered_x{1:k-1},{x_centered},...
coordinates.x_3chemotaxis_Cytoplasts.centered_x{k:end}];

y_centered=y-y(1);

coordinates.x_3chemotaxis_Cytoplasts.centered_y=...
[coordinates.x_3chemotaxis_Cytoplasts.centered_y{1:k-1},{y_centered},...
coordinates.x_3chemotaxis_Cytoplasts.centered_y{k:end}];

[theta,rho] = cart2pol(x_centered,y_centered);

coordinates.x_3chemotaxis_Cytoplasts.theta=...
[coordinates.x_3chemotaxis_Cytoplasts.theta{1:k-1},{theta},...
coordinates.x_3chemotaxis_Cytoplasts.theta{k:end}];

coordinates.x_3chemotaxis_Cytoplasts.rho=...
[coordinates.x_3chemotaxis_Cytoplasts.rho{1:k-1},{rho},...
coordinates.x_3chemotaxis_Cytoplasts.rho{k:end}];

scaled_rho = rho/39.6252;
scaled_x = x_centered/39.6252;
scaled_y = y_centered/39.6252;

coordinates.x_3chemotaxis_Cytoplasts.scaled_rho=...
[coordinates.x_3chemotaxis_Cytoplasts.scaled_rho{1:k-1},{scaled_rho},...
coordinates.x_3chemotaxis_Cytoplasts.scaled_rho{k:end}];

coordinates.x_3chemotaxis_Cytoplasts.scaled_x=...
[coordinates.x_3chemotaxis_Cytoplasts.scaled_x{1:k-1},{scaled_x},...
coordinates.x_3chemotaxis_Cytoplasts.scaled_x{k:end}];

coordinates.x_3chemotaxis_Cytoplasts.scaled_y=...
[coordinates.x_3chemotaxis_Cytoplasts.scaled_y{1:k-1},{scaled_y},...
coordinates.x_3chemotaxis_Cytoplasts.scaled_y{k:end}];




coordinates.x_3chemotaxis_Cytoplasts.shuffled_x=...
[coordinates.x_3chemotaxis_Cytoplasts.shuffled_x{1:k-1},{scaled_x},...
coordinates.x_3chemotaxis_Cytoplasts.shuffled_x{k:end}];

coordinates.x_3chemotaxis_Cytoplasts.shuffled_y=...
[coordinates.x_3chemotaxis_Cytoplasts.shuffled_y{1:k-1},{scaled_y},...
coordinates.x_3chemotaxis_Cytoplasts.shuffled_y{k:end}];

coordinates.x_3chemotaxis_Cytoplasts.shuffled_rho=...
[coordinates.x_3chemotaxis_Cytoplasts.shuffled_rho{1:k-1},{scaled_rho},...
coordinates.x_3chemotaxis_Cytoplasts.shuffled_rho{k:end}];

tic
for z=1:200000
  coordinates.x_3chemotaxis_Cytoplasts.shuffled_rho{k} = ...
      shuff(coordinates.x_3chemotaxis_Cytoplasts.shuffled_rho{k}) ;

  coordinates.x_3chemotaxis_Cytoplasts.shuffled_x{k} = ...
      shuff(coordinates.x_3chemotaxis_Cytoplasts.shuffled_x{k}) ;

  coordinates.x_3chemotaxis_Cytoplasts.shuffled_y{k} = ...
      shuff(coordinates.x_3chemotaxis_Cytoplasts.shuffled_y{k}) ;
end
toc

