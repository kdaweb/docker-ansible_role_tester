pipeline {
  agent any

  stages {
    stage('Test') {
      steps {
        sh 'docker run -v $(pwd):/tests/roles/test kdaweb/ansible_role_tester test_ansible_role.sh'
      }
    }

    stage('Lint') {
      steps {
        sh 'docker run -v $(pwd):/tests/roles/test kdaweb/ansible_role_tester lint_ansible_role.sh'
      }
    }

  }
}
