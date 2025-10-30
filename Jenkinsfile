pipeline {
  agent any

  options {
    timestamps()
    ansiColor('xterm')
    disableConcurrentBuilds()
  }

  environment {
    ANSIBLE_CONFIG = 'ansible/ansible.cfg'
    TF_WORKDIR     = 'terraform/aws-ec2'
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Setup tooling') {
      steps {
        sh '''
          # Ansible
          if ! command -v ansible >/dev/null; then
            sudo apt-get update && sudo apt-get install -y ansible
          fi

          # Terraform
          if ! command -v terraform >/dev/null; then
            curl -fsSL https://releases.hashicorp.com/terraform/1.9.5/terraform_1.9.5_linux_amd64.zip -o /tmp/tf.zip
            sudo unzip -o /tmp/tf.zip -d /usr/local/bin
          fi
        '''
      }
    }

    stage('YAML lint') {
      steps {
        sh '''
          if ! command -v yamllint >/dev/null; then
            sudo pip3 install yamllint
          fi
          yamllint -s .
        '''
      }
    }

    stage('Ansible syntax') {
      steps {
        sh '''
          ansible-playbook -i ansible/inventories/hosts ansible/playbooks/patch.yml --syntax-check
        '''
      }
    }

    stage('Terraform fmt/validate') {
      steps {
        sh '''
          cd "$TF_WORKDIR"
          terraform init -input=false
          terraform fmt -check
          terraform validate -no-color
        '''
      }
    }

    stage('Summary') {
      steps {
        echo "All checks passed ✅"
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: '**/terraform.tfstate.backup', allowEmptyArchive: true
    }
  }
}
