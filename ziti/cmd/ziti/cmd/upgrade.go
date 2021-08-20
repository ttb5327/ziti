/*
	Copyright NetFoundry, Inc.

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	https://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

package cmd

import (
	"io"

	cmdutil "github.com/openziti/ziti/ziti/cmd/ziti/cmd/factory"
	cmdhelper "github.com/openziti/ziti/ziti/cmd/ziti/cmd/helpers"
	"github.com/openziti/ziti/ziti/cmd/ziti/cmd/templates"
	"github.com/spf13/cobra"
)

// UpgradeOptions are the flags for delete commands
type UpgradeOptions struct {
	CommonOptions
}

var (
	upgrade_long = templates.LongDesc(`
		Upgrade the Ziti platform binaries.
`)

	upgrade_example = templates.Examples(`
		# upgrade the command line tool
		ziti upgrade cli
	`)
)

// NewCmdUpgrade creates the command
func NewCmdUpgrade(f cmdutil.Factory, out io.Writer, errOut io.Writer) *cobra.Command {
	options := &UpgradeOptions{
		CommonOptions{
			Factory: f,
			Out:     out,
			Err:     errOut,
		},
	}

	cmd := &cobra.Command{
		Use:     "upgrade [flags]",
		Short:   "Upgrades a Ziti component/app",
		Long:    upgrade_long,
		Example: upgrade_example,
		Aliases: []string{"bump"},
		Run: func(cmd *cobra.Command, args []string) {
			options.Cmd = cmd
			options.Args = args
			err := options.Run()
			cmdhelper.CheckErr(err)
		},
		SuggestFor: []string{"up"},
	}

	cmd.AddCommand(NewCmdUpgradeZiti(f, out, errOut))
	cmd.AddCommand(NewCmdUpgradeZitiController(f, out, errOut))
	cmd.AddCommand(NewCmdUpgradeZitiFabric(f, out, errOut))
	cmd.AddCommand(NewCmdUpgradeZitiFabricTest(f, out, errOut))
	cmd.AddCommand(NewCmdUpgradeZitiMgmtGw(f, out, errOut))
	cmd.AddCommand(NewCmdUpgradeZitiRouter(f, out, errOut))
	cmd.AddCommand(NewCmdUpgradeZitiTunnel(f, out, errOut))
	cmd.AddCommand(NewCmdUpgradeZitiProxC(f, out, errOut))
	cmd.AddCommand(NewCmdUpgradeZitiEdgeTunnel(f, out, errOut))

	return cmd
}

// Run implements this command
func (o *UpgradeOptions) Run() error {
	return o.Cmd.Help()
}
