// Copyright (c) 2020 TypeFox GmbH. All rights reserved.
// Licensed under the Gitpod Enterprise Source Code License,
// See License.enterprise.txt in the project root folder.

package poolkeeper

import (
	"context"
	"time"

	// corev1 "k8s.io/api/core/v1"
	// metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	// types "k8s.io/apimachinery/pkg/types"
	"k8s.io/client-go/kubernetes"

	log "github.com/sirupsen/logrus"
)

// PoolKeeper is the entity responsiple to perform the configures actions per NodePool
type PoolKeeper struct {
	Clientset *kubernetes.Clientset
	Config    *Config

	stop chan struct{}
	done chan struct{}
}

// NewPoolKeeper creates a new PoolKeeper instance
func NewPoolKeeper(clientset *kubernetes.Clientset, config *Config) *PoolKeeper {
	return &PoolKeeper{
		Clientset: clientset,
		Config:    config,

		stop: make(chan struct{}, 1),
		done: make(chan struct{}, 1),
	}
}

// Start starts the PoolKeeper and is meant to be run in a goroutine
func (pk *PoolKeeper) Start() {
	defer func() {
		pk.done <- struct{}{}
	}()

	ctx, cancel := context.WithCancel(context.Background())
	for _, task := range pk.Config.Tasks {
		go func(ctx context.Context, task *Task) {
			ticker := time.NewTicker(time.Duration(task.Interval))
			for {
				if task.PatchDeploymentAffinity != nil {
					log.WithField("task", task.Name).Infof("start patching deployments...")
					task.PatchDeploymentAffinity.run(pk.Clientset)
					log.WithField("task", task.Name).Infof("done patching deployments.")
				}

				select {
				case <-ctx.Done():
					return
				case <-ticker.C:
					continue
				}
			}
		}(ctx, task)
	}

	<-pk.stop
	log.Debug("stopping...")
	cancel()
}

// Stop stops PoolKeeper and waits until is has done so
func (pk *PoolKeeper) Stop() {
	pk.stop <- struct{}{}
	<-pk.done
}
