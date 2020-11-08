#!/bin/bash

set -eux

git clone https://github.com/scala-steward-org/scala-steward.git

cd scala-steward

# https://github.com/scala-steward-org/scala-steward/pull/1719#discussion_r519446225
git checkout 2b373382d7dca51987780cb5bbab466305e0a645

mkdir modules/core/.jvm

echo "echo $1" > modules/core/.jvm/github_token.sh

chmod +x modules/core/.jvm/github_token.sh

echo "- $GITHUB_REPOSITORY" > modules/core/.jvm/repos.md

cs install scalafmt

echo 'TaskKey[Unit]("runGitHubAction") := Def.taskDyn {
  val args = Seq(
    Seq("--disable-sandbox"),
    Seq("--do-not-fork"),
    Seq("--workspace", "workspace"),
    Seq("--repos-file", "repos.md"),
    Seq("--git-author-email", "41898282+github-actions[bot]@users.noreply.github.com"),
    Seq("--vcs-login", "github-actions[bot]"),
    Seq("--git-ask-pass", "github_token.sh"),
  ).flatten.mkString(" ", " ", "")
  (LocalProject("core") / Compile / run).toTask(args)
}.value' > run.sbt

sbt runGitHubAction
