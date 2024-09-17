require 'octokit'

# Autenticação no GitHub
private_repo_token = ENV['PRIVATE_REPO_TOKEN']
public_repo_token = ENV['PUBLIC_REPO_TOKEN']
private_repo = ENV['PRIVATE_REPO']
public_repo = ENV['PUBLIC_REPO']

private_client = Octokit::Client.new(access_token: private_repo_token)
public_client = Octokit::Client.new(access_token: public_repo_token)

# Obter issues do repositório público
def fetch_public_issues(client, repo)
  issues = client.issues(repo)
  issues.map { |issue| { title: issue.title, body: issue.body, number: issue.number } }
end

# Criar issue no repositório privado
def create_private_issue(client, repo, title, body)
  client.create_issue(repo, title, body)
end

# Sincronizar as issues do repositório público para o privado
def sync_issues(private_client, public_client, private_repo, public_repo)
  public_issues = fetch_public_issues(public_client, public_repo)
  
  public_issues.each do |issue|
    puts "Sincronizando Issue ##{issue[:number]} - #{issue[:title]}"
    
    # Verifica se a issue já existe no repositório privado
    existing_issues = private_client.issues(private_repo)
    if existing_issues.any? { |i| i.title == issue[:title] }
      puts "Issue já existe no repositório privado. Pulando..."
    else
      # Cria a issue no repositório privado
      create_private_issue(private_client, private_repo, issue[:title], issue[:body])
      puts "Issue criada com sucesso no repositório privado."
    end
  end
end

# Executa a sincronização
sync_issues(private_client, public_client, private_repo, public_repo)
