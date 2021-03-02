// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import 'bootstrap';
import css from "../css/app.scss"


// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"
import analyticsDiagram from "./analytics_diagram"

import jQuery from "jquery"
window.jQuery = jQuery

import Alpine from "alpinejs";

import { Socket } from "phoenix"
import { LiveSocket, debug } from "phoenix_live_view"

let Hooks = {}

// Analytics diagram
Hooks.AnalyticsDiagram = {
    mounted() {
        let data = this.el.getAttribute("data-analytics-data")
        analyticsDiagram(JSON.parse(data), '#analytics-diagram')
    },

    updated() {
        let data = this.el.getAttribute("data-analytics-data")
        analyticsDiagram(JSON.parse(data), '#analytics-diagram')
    }
}

// Finance diagram
Hooks.FinanceDiagram = {
    mounted() {
        let data = this.el.getAttribute("data-finance-data")
        console.log(data)
        analyticsDiagram(JSON.parse(data), '#finance-diagram')
    },

    updated() {
        let data = this.el.getAttribute("data-finance-data")
        analyticsDiagram(JSON.parse(data), '#finance-diagram')
    }
}

// Tooltips
Hooks.TooltipInit = {
    mounted() {
        // Tooltips
        jQuery('[data-toggle="tooltip"]').tooltip()
    }
}

// Input autofocus and cancel create
Hooks.Focus = {
    mounted() {
        let componentSelector = "#" + this.el.getAttribute("data-component")
        this.el.focus()
        this.el.addEventListener("keyup", e => {
            if (e.keyCode == 27) {
                this.pushEventTo(componentSelector, "cancel", {})
            }
        })
        this.el.addEventListener("focusout", e => {
            this.pushEventTo(componentSelector, "cancel", {})
        })
    }
}

const getListId = event => event.target.closest(".list").getAttribute("phx-value-list_id")

Hooks.Draggable = {
    mounted() {
        this.el.addEventListener("dragstart", event => {
            event.target.style.opacity = .7
            const type = event.target.getAttribute("phx-value-draggable_type")
            const id = event.target.getAttribute("phx-value-draggable_id")
            event.dataTransfer.setData("text/plain", type + "," + id)
        }, false)

        this.el.addEventListener("dragend", event => {
            event.target.style.opacity = 1
        }, false)

        this.el.addEventListener("drop", event => {
            event.preventDefault()
            event.target.style.opacity = 1
        }, false)
    }
}

Hooks.DropContainer = {
    mounted() {
        this.el.addEventListener("dragover", event => {
            event.preventDefault()
        }, false)

        this.el.addEventListener("dragenter", event => {
            let list = event.target.closest(".list")
            list.classList.add("drag-target-active")
        }, false)

        this.el.addEventListener("dragleave", event => {
            let list = event.target.closest(".list")
            list.classList.remove("drag-target-active")
        }, false)

        this.el.addEventListener("drop", event => {
            event.preventDefault()
            let list = event.target.closest(".list")
            list.classList.remove("drag-target-active")
            const draggable = event.dataTransfer.getData("text/plain").split(",")
            const type = draggable[0]
            const id = draggable[1]
            switch (type) {
                case "item":
                    {
                        this.pushEvent("move_item", { id: id, to_list_id: getListId(event) })
                    }
                    break
                case "list":
                    {
                        this.pushEvent("swap_lists", { id: id, to_list_id: getListId(event) })
                    }
                    break
            }
        }, false)
    }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
    hooks: Hooks,
    params: { _csrf_token: csrfToken },
    dom: {
        onBeforeElUpdated(from, to) {
            if (from.__x) {
                Alpine.clone(from.__x, to);
            }
        }
    }
})
liveSocket.connect()
// liveSocket.enableDebug()

window.liveSocket = liveSocket
