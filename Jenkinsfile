pipeline {
    agent any

    environment {
        GITHUB_TOKEN = credentials('github-token')
        GITHUB_REPO = 'cyse7125-su24-team13/infra-aws'
        GITHUB_API_URL = 'https://api.github.com'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    def scmVars = checkout scm
                    def commitId = scmVars.GIT_COMMIT
                    env.GIT_COMMIT_ID = commitId
                }
            }
        }

        stage('Commit Message Lint') {
            steps {
                script {
                    checkCommitMessages()
                }
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }
    }

    post {
        success {
            script {
                def commitId = env.GIT_COMMIT_ID
                def status = 'success'
                def description = 'Terraform validation successful.'
                notifyGithub(commitId, status, description)
            }
        }

        failure {
            script {
                def commitId = env.GIT_COMMIT_ID
                def status = 'failure'
                def description = 'Terraform validation failed.'
                notifyGithub(commitId, status, description)
            }
        }
    }
}

def notifyGithub(commitId, status, description) {
    def context = 'Terraform'
    def url = "${env.GITHUB_API_URL}/repos/${env.GITHUB_REPO}/statuses/${commitId}"

    def payload = [
        state: status,
        target_url: env.BUILD_URL,
        description: description,
        context: context
    ]

    def response = sh(
        script: """#!/bin/bash
        curl -s -H "Authorization: token ${env.GITHUB_TOKEN}" \\
             -H "Content-Type: application/json" \\
             -d '${groovy.json.JsonOutput.toJson(payload)}' \\
             ${url}
        """,
        returnStdout: true
    ).trim()

    echo "GitHub API response: ${response}"
}

def checkCommitMessages() {
    def commitMessages = sh(script: 'git log --pretty=format:%s origin/main..HEAD', returnStdout: true).trim().split('\n')
    def conventionalCommitRegex = /^(feat|fix|docs|style|refactor|perf|test|chore|build|ci|revert|wip)(\(.+\))?: .{1,50}/

    if (commitMessages.size() == 0 || (commitMessages.size() == 1 && commitMessages[0] == '')) {
        echo "No new commits to validate."
    } else {
        for (commitMessage in commitMessages) {
            if (commitMessage.startsWith("Merge ")) {
                echo "Merge commit detected, skipping Conventional Commits check for this commit."
            } else if (!commitMessage.matches(conventionalCommitRegex)) {
                error("Commit message does not follow the Conventional Commits specification. Commit message: ${commitMessage}")
            } else {
                echo "Commit message is valid: ${commitMessage}"
            }
        }
    }
}
