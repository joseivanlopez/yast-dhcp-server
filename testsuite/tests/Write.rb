# encoding: utf-8

# File:
#  rw.ycp
#
# Module:
#  DHCP server configurator
#
# Summary:
#  Read and write testsuite
#
# Authors:
#  Jiri Srain <jsrain@suse.cz>
#
# $Id$
#
module Yast
  class WriteClient < Client
    def main
      Yast.include self, "testsuite.rb"

      # testedfiles: DhcpServer.pm systemctl.rb

      TESTSUITE_INIT([], nil)
      Yast.import "Progress"
      Yast.import "DhcpServer"
      Yast.import "Mode"

      Mode.SetTest("testsuite")

      @progress_orig = Progress.set(false)

      @READ = {
        # Runlevel
        "init"      => {
          "scripts" => {
            "exists"   => true,
            "runlevel" => { "dhcpd" => { "start" => [], "stop" => [] } },
            # their contents is not important for ServiceAdjust
            "comment"  => {
              "dhcpd" => {}
            }
          }
        },
        "target"    => { "stat" => {}, "ycp" => {} },
        "sysconfig" => {
          "SuSEfirewall2" => {
            "FW_SERVICE_DNS"      => "no",
            "FW_SERVICE_DHCLIENT" => "no",
            "FW_SERVICE_DHCPD"    => "no",
            "FW_SERVICE_SQUID"    => "no",
            "FW_SERVICE_SAMBA"    => "no"
          }
        },
        "product"   => {
          "features" => {
            "USE_DESKTOP_SCHEDULER"           => "0",
            "ENABLE_AUTOLOGIN"                => "0",
            "EVMS_CONFIG"                     => "0",
            "IO_SCHEDULER"                    => "cfg",
            "UI_MODE"                         => "expert",
            "INCOMPLETE_TRANSLATION_TRESHOLD" => "95"
          }
        }
      }
      @WRITE = {}
      @EXEC = {
        "target" => {
          "bash_output" => {
            "exit" => 0,
            "stderr" => "",
            "stdout" => "",
          }
        }
      }

      DhcpServer.SetModified

      TEST(lambda { DhcpServer.Write }, [@READ, @WRITE, @EXEC], 0)
      DUMP("===============================")
      TEST(lambda do
        DhcpServer.Import(
          {
            "allowed_interfaces" => ["eth0", "eth2"],
            "chroot"             => "0",
            "other_options"      => "-p 111",
            "settings"           => [
              {
                "children"       => [],
                "comment_after"  => nil,
                "comment_before" => nil,
                "directives"     => [],
                "id"             => "",
                "options"        => [
                  {
                    "comment_after"  => "",
                    "comment_before" => "# dhcpd.conf",
                    "key"            => "domain-name",
                    "type"           => "option",
                    "value"          => "\"example.org\""
                  },
                  {
                    "comment_after"  => "",
                    "comment_before" => "",
                    "key"            => "domain-name-servers",
                    "type"           => "option",
                    "value"          => "ns1.example.org, ns2.example.org"
                  },
                  {
                    "comment_after"  => "",
                    "comment_before" => "",
                    "key"            => "policy-filter",
                    "type"           => "option",
                    "value"          => "{ a1, a2 }, { a1, a2 }, { a3, a4 }"
                  }
                ],
                "parent_id"      => "",
                "parent_type"    => "",
                "type"           => ""
              }
            ],
            "start_service"      => "0"
          } #
          # $[
          # 	"allowed_interfaces":["0"],
          # 	"chroot":"1",
          # 	"settings":[
          # 	    $[
          # 		"children":[],
          # 		"comment_after":nil,
          # 		"comment_before":nil,
          # 		"directives":[],
          # 		"id":"",
          # 		"options":[
          # 		    $[
          # 			"comment_after":"",
          # 			"comment_before":"# dhcpd.conf",
          # 			"key":"domain-name",
          # 			"type":"option",
          # 			"value":"\"example.org\""
          # 		    ],
          # 		    $[
          # 			"comment_after":"",
          # 			"comment_before":"",
          # 			"key":"domain-name-servers",
          # 			"type":"option",
          # 			"value":"ns1.example.org, ns2.example.org"
          # 		    ],
          # 		    $[
          # 			"comment_after":"",
          # 			"comment_before":"",
          # 			"key":"policy-filter",
          # 			"type":"option",
          # 			"value":"{ a1, a2 }, { a1, a2 }, { a3, a4 }"
          # 		    ]
          # 		],
          # 		"parent_id":"",
          # 		"parent_type":"",
          # 		"type":""
          # 	    ]
          # 	],
          # 	"start_service":"0"
          #     ]
        )
      end, [], 0)
      DUMP("===============================")
      TEST(lambda { DhcpServer.Write }, [@READ, @WRITE, @EXEC], 0)

      nil
    end
  end
end

Yast::WriteClient.new.main
