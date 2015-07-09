clear
hold off

data = load('fd_vs_adj.txt')

% add column of 1's to X data (fd values)
X = [ones(size(data,1),1) data(:,1)]

% y is adj values
y = data(:,2)

%h=subplot(3,3,i)

% regress
[b,bint,r,rint,stats] = regress(y,X)

% scatter plot 


scatter(X(:,2),y,'SizeData',64, 'LineWidth',2)
xlabel('Finite Difference','Fontsize',20,'Fontweight','bold')
ylabel('Adjoint','Fontsize',20,'Fontweight','bold')

% hold
hold

% plot fit line
y_hat = X(:,2)*b(2) + b(1)

h2=plot(X(:,2),y_hat,':', 'LineWidth',2)
%legend(h2,'r^2 = ',)
%legend('boxoff')


% get current plot axis
axis('tight')
ax = axis

% set x and y axis equal to each other, picking the largest
y_max = max(ax(2),ax(4))
y_min = min(ax(1),ax(3))
haxis=gca
set(haxis,'Fontsize',20, 'Fontweight','bold')


% get r^2, put it in a string
str_r2 = strcat(' r^2 =', ' ', num2str(fixdig(stats(1),3)))

% get m as a string
str_b2 = strcat(' m =', ' ', num2str(fixdig(b(2),3)))


        % put strings on plot
    text(y_min,y_max*0.8,str_r2,'Fontsize',20,'Fontweight','bold')
    text(y_min,y_max*0.5,str_b2,'Fontsize',20,'Fontweight','bold')





% Reset axis
% get current plot axis
axis('tight')
ax = axis

% set x and y axis equal to each other, picking the largest
y_max = max(ax(2),ax(4))
y_min = min(ax(1),ax(3))

% add a little border
y_max = y_max + 0.05*y_max
y_min = y_min + 0.05*y_min

axis([y_min y_max y_min y_max])


% plot a 1:1 line
temp = [y_min, y_max]
plot(temp, temp, 'color', 'black', 'LineWidth', 2)
