FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY dist/ /usr/share/nginx/html/
RUN printf 'server{\nlisten 80;\nroot /usr/share/nginx/html;\nindex index.html;\nlocation/{\ntry_files $uri $uri/ /index.html;\n}\n}' > /etc/nginx/conf.d/default.conf
EXPOSE 80
