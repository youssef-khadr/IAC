echo $*
echo hello
echo $1
echo $2
aws ecr get-login-password --region $1 | docker login --username AWS --password-stdin $2

script {
  def repoURL = sh (returnStdout: true, script:'terraform output ecrRepositoryURL')
  def awsRegion = sh (returnStdout: true, script:'terraform output awsRegion')
  sh """
    docker tag my-container:latest ${repoURL}
    aws ecr get-login-password --region ${awsRegion} 
    docker login --username AWS --password-stdin ${repoURL}
    docker push ${repoURL}:latest
    """
}




def repoURL = sh (returnStdout: true, script:'terraform output ecrRepositoryURL')
            def awsRegion = sh (returnStdout: true, script:'terraform output awsRegion')
            def command = $/"aws ecr get-login-password --region ${awsRegion} | docker login --username AWS --password-stdin ${repoURL}"/$
            res = sh(returnStdout: true, script: command)
            sh "docker tag my-container:latest ${repoURL}"
            sh "docker push ${repoURL}:latest"
            
            aws ecr --region ${awsRegion} | docker login -u AWS -p  ${repoURL}
            
            cmd="aws ecr get-login-password --region ${awsRegion}"
            url=$($cmd | awk '{ print $7 }')
            $cmd | awk '{ print $6 }' | docker login --username AWS --password-stdin ${repoURL}
            
script {
  def repoURL = sh (returnStdout: true, script:'terraform output ecrRepositoryURL')
  def awsRegion = sh (returnStdout: true, script:'terraform output awsRegion')
  sh """
    docker tag my-container:latest ${repoURL}
    aws ecr get-login-password --region ${awsRegion}\\| docker login --username AWS --password-stdin ${repoURL}
    docker push ${repoURL}:latest
    """
}               

script {
  def repoURL = sh (returnStdout: true, script:'terraform output ecrRepositoryURL')
  def awsRegion = sh (returnStdout: true, script:'terraform output awsRegion')
  sh '''#!/bin/bash
    docker tag my-container:latest ${repoURL}
    aws ecr get-login-password --region ${awsRegion} | docker login --username AWS --password-stdin ${repoURL}
    docker push ${repoURL}:latest
    '''
}

script {
  def repoURL = sh (returnStdout: true, script:'terraform output ecrRepositoryURL')
  def awsRegion = sh (returnStdout: true, script:'terraform output awsRegion')
  sh """#!/bin/bash
    docker tag my-container:latest ${repoURL}
    aws ecr get-login-password --region ${awsRegion} | docker login --username AWS --password-stdin ${repoURL}
    docker push ${repoURL}:latest
    """
}
