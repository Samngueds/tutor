require 'octokit'

# Recebe os tokens e nomes dos repositórios do ambiente
public_repo_token = ENV['PUBLIC_REPO_TOKEN']
private_repo_token = ENV['PRIVATE_REPO_TOKEN']
public_repo = ENV['PUBLIC_REPO']     # Nome do repositório público (ex: "usuario/repo_publico")
private_repo = ENV['PRIVATE_REPO']   # Nome do repositório privado (central)

# Configura os clientes Octokit para os repositórios
public_client = Octokit::Client.new(access_token: public_repo_token)
private_client = Octokit::Client.new(access_token: private_repo_token)

def fetch_issues(client, repo)
  puts "Buscando issues do repositório #{repo}..."
  issues = client.issues(repo, state: 'all').map do |issue|
    { number: issue.number, title: issue.title, body: issue.body }
  end
  puts "Issues encontradas: #{issues.size}"
  issues
rescue => e
  puts "Erro ao buscar issues: #{e.message}"
  []
end

def create_issue(client, repo, title, body)
  puts "Criando issue no repositório #{repo}..."
  client.create_issue(repo, title, body)
  puts "Issue criada: #{title}"
rescue => e
  puts "Erro ao criar issue: #{e.message}"
end

def synchronize_issues(source_client, source_repo, target_client, target_repo)
  puts "Sincronizando issues do repositório #{source_repo} para #{target_repo}..."
  source_issues = fetch_issues(source_client, source_repo)
  target_issues = fetch_issues(target_client, target_repo)

  source_issues.each do |issue|
    unless target_issues.any? { |i| i[:title] == issue[:title] }
      create_issue(target_client, target_repo, issue[:title], issue[:body])
    end
  end

  puts "Sincronização concluída entre #{source_repo} e #{target_repo}."
end

puts "Iniciando sincronização de issues..."

# Sincroniza do repositório público para o repositório privado (central)
synchronize_issues(public_client, public_repo, private_client, private_repo)

# Sincroniza do repositório privado (central) para o repositório público
synchronize_issues(private_client, private_repo, public_client, public_repo)
