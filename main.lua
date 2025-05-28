local port = 8080
print("Starting SolVM web server on port " .. port)

create_server("main_server", port, false)

handle_http("main_server", "/", function(req)
    local html_content = [[
<!DOCTYPE html>
<html>
<head>
    <title>TabNews Feed</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f0f2f5;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .post {
            border-bottom: 1px solid #eee;
            padding: 15px 0;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .post:hover {
            background-color: #f8f9fa;
        }
        .post:last-child {
            border-bottom: none;
        }
        .post-title {
            color: #1a73e8;
            margin: 0 0 10px 0;
        }
        .post-meta {
            color: #666;
            font-size: 0.9em;
        }
        .post-content {
            white-space: pre-wrap;
            line-height: 1.6;
        }
        .back-button {
            display: inline-block;
            margin-bottom: 20px;
            color: #1a73e8;
            text-decoration: none;
        }
        .back-button:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>TabNews Feed</h1>
        <div id="posts"></div>
    </div>

    <script>
        function loadPosts() {
            fetch('https://www.tabnews.com.br/api/v1/contents')
                .then(response => response.json())
                .then(posts => {
                    const postsDiv = document.getElementById('posts');
                    posts.forEach(post => {
                        const postElement = document.createElement('div');
                        postElement.className = 'post';
                        postElement.onclick = () => window.location.href = '/post/' + post.owner_username + '/' + post.slug;
                        postElement.innerHTML = `
                            <h2 class="post-title">${post.title}</h2>
                            <div class="post-meta">
                                Por ${post.owner_username} • ${new Date(post.created_at).toLocaleDateString('pt-BR')}
                            </div>
                        `;
                        postsDiv.appendChild(postElement);
                    });
                })
                .catch(error => console.error('Erro ao carregar posts:', error));
        }

        function loadPost(username, slug) {
            fetch(`https://www.tabnews.com.br/api/v1/contents/${username}/${slug}`)
                .then(response => response.json())
                .then(post => {
                    const container = document.querySelector('.container');
                    container.innerHTML = `
                        <a href="/" class="back-button">← Voltar para o feed</a>
                        <h1>${post.title}</h1>
                        <div class="post-meta">
                            Por ${post.owner_username} • ${new Date(post.created_at).toLocaleDateString('pt-BR')}
                        </div>
                        <div class="post-content">${post.body}</div>
                    `;
                })
                .catch(error => console.error('Erro ao carregar post:', error));
        }

        const path = window.location.pathname;
        if (path.startsWith('/post/')) {
            const [, , username, slug] = path.split('/');
            loadPost(username, slug);
        } else {
            loadPosts();
        }
    </script>
</body>
</html>
    ]]
    
    return {
        status = 200,
        headers = {
            ["Content-Type"] = "text/html"
        },
        body = html_content
    }
end)

handle_http("main_server", "/post/*", function(req)
    local html_content = [[
<!DOCTYPE html>
<html>
<head>
    <title>TabNews Post</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f0f2f5;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .post {
            border-bottom: 1px solid #eee;
            padding: 15px 0;
        }
        .post:last-child {
            border-bottom: none;
        }
        .post-title {
            color: #1a73e8;
            margin: 0 0 10px 0;
        }
        .post-meta {
            color: #666;
            font-size: 0.9em;
        }
        .post-content {
            white-space: pre-wrap;
            line-height: 1.6;
        }
        .back-button {
            display: inline-block;
            margin-bottom: 20px;
            color: #1a73e8;
            text-decoration: none;
        }
        .back-button:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <a href="/" class="back-button">← Voltar para o feed</a>
        <div id="post-content"></div>
    </div>

    <script>
        const path = window.location.pathname;
        const [, , username, slug] = path.split('/');
        
        fetch(`https://www.tabnews.com.br/api/v1/contents/${username}/${slug}`)
            .then(response => response.json())
            .then(post => {
                const postDiv = document.getElementById('post-content');
                postDiv.innerHTML = `
                    <h1>${post.title}</h1>
                    <div class="post-meta">
                        Por ${post.owner_username} • ${new Date(post.created_at).toLocaleDateString('pt-BR')}
                    </div>
                    <div class="post-content">${post.body}</div>
                `;
            })
            .catch(error => console.error('Erro ao carregar post:', error));
    </script>
</body>
</html>
    ]]
    
    return {
        status = 200,
        headers = {
            ["Content-Type"] = "text/html"
        },
        body = html_content
    }
end)

start_server("main_server")
print("Server started. Access at http://localhost:" .. port)

while true do
    sleep(1)
end 