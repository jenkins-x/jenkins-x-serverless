@Grab('org.yaml:snakeyaml:1.17')

import groovy.json.*
import org.yaml.snakeyaml.Yaml

String.metaClass.isLaterVersionThan = { String version -> 
    List verA = version.split("-")[0].tokenize('.')
    List verB = delegate.split("-")[0].tokenize('.')

    def commonIndices = Math.min(verA.size(), verB.size())

    for (int i = 0; i < commonIndices; ++i) {
      	def numA = verA[i].toInteger()
      	def numB = verB[i].toInteger()

      	if (numA != numB) {
        	return numA < numB
      	}
    }

    return verA.size() < verB.size()
}

assert '4'.isLaterVersionThan('2')
assert '4.1'.isLaterVersionThan('4')
assert '5'.isLaterVersionThan('4.1')
assert '02.2.02.03'.isLaterVersionThan('02.2.02.01')
assert '2.60.2'.isLaterVersionThan('1.625.3')
assert '1.1'.isLaterVersionThan('1.0-rc2')

assert !'2'.isLaterVersionThan('4')
assert !'4'.isLaterVersionThan('4.1')
assert !'4.1'.isLaterVersionThan('5')
assert !'02.2.02.01'.isLaterVersionThan('02.2.02.03')
assert !'1.625.3'.isLaterVersionThan('2.60.2')

def jenkinsVersion = "2.150.1"

Yaml parser = new Yaml()
def config = parser.load(("packager-config.yml" as File).text)

def plugins = []
config.plugins.each { plugin ->
	plugins << [group: plugin.groupId, artifact: plugin.artifactId, version: plugin.source.version]
}

def content = "https://updates.jenkins.io/current/update-center.actual.json".toURL().text

def jsonSlurper = new JsonSlurper()
def meta = jsonSlurper.parseText(content)

plugins.each { plugin -> 
	def upgrade = meta.plugins.find { it.value.gav.startsWith("${plugin.group}:${plugin.artifact}") }
	if (upgrade) {
		if (upgrade.value.version.isLaterVersionThan(plugin.version)) {
			println "Found upgrade for ${plugin.group}:${plugin.artifact}: ${plugin.version} -> ${upgrade.value.version}"
		}
	}
}
