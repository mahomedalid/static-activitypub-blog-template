const dateOptions = {
    year: "numeric",
    month: "numeric",
    day: "numeric",
    hour: "numeric",
    minute: "numeric"
};

function escapeHtml(e) {
    return e.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;")
}

function emojify(e, t) {
    let n = e;
    return t.forEach(e => {
        let s = document.createElement("picture"),
            o = document.createElement("source");
        o.setAttribute("srcset", escapeHtml(e.url)), o.setAttribute("media", "(prefers-reduced-motion: no-preference)");
        let t = document.createElement("img");
        t.className = "emoji", t.setAttribute("src", escapeHtml(e.static_url)), t.setAttribute("alt", `:${e.shortcode}:`), t.setAttribute("title", `:${e.shortcode}:`), t.setAttribute("width", "20"), t.setAttribute("height", "20"), s.appendChild(o), s.appendChild(t), n = n.replace(`:${e.shortcode}:`, s.outerHTML)
    }), n
}

function getStatusUrl(originalUrl) {
    // Parse the original URL
    let url = new URL(originalUrl);
    
    // Extract the host and id
    let host = url.host;
    let id = url.pathname.split('/').pop(); // Extract the id from the last part of the pathname
    
    // Construct the modified URL
    let modifiedUrl = "https://" + host + "/api/v1/statuses/" + id;
    
    return modifiedUrl;
}


function loadCommentsFromMastodon(repliesUrl, commentsWrapper) {
    fetch(repliesUrl)
      .then(function(response) {
        if (response.ok) {
          return response.json();
        }

        if (response.status === 404) {
          // Handle 404 error here
          console.log("Comments not found");
          return Promise.reject("Comments not found");
        }
        
        // Handle other errors here
        return Promise.reject("Error fetching comments");
      })
      .then(function(data) {
        let promises = data.items.map(function(replyId) {
          return fetch(getStatusUrl(replyId), {
            headers: {
              'Content-Type': 'application/activity+json',
              'Accept': 'application/activity+json'
            }
          }).then(function(response) {
            if (!response.ok) {
              console.log("Error fetching reply:", response.statusText);
              return Promise.reject("Error fetching reply");
            }
            return response.json();
          });
        });
        
        return Promise.all(promises);
      }).then(function(responses) {
        responses.sort((a, b) => new Date(a.created_at) - new Date(b.created_at));

        commentsWrapper.innerHTML = "";

        let n = responses;
        let e = commentsWrapper;
        n && Array.isArray(n) && n.length > 0 && (e.innerHTML = "", n.forEach(function(t) {
            console.log(n), t.account.display_name.length > 0 ? (t.account.display_name = escapeHtml(t.account.display_name), t.account.display_name = emojify(t.account.display_name, t.account.emojis)) : t.account.display_name = t.account.username;
            let a = "";
            t.account.acct.includes("@") ? a = t.account.acct.split("@")[1] : a = "xxxxxx.social";
            const v = t.in_reply_to_id !== "xxxx01";
            let p = !1;
            t.account.acct == "xxxxacct" && (p = !0), t.content = emojify(t.content, t.emojis);
            let h = document.createElement("source");
            h.setAttribute("srcset", escapeHtml(t.account.avatar)), h.setAttribute("media", "(prefers-reduced-motion: no-preference)");
            let d = document.createElement("img");
            d.className = "avatar", d.setAttribute("src", escapeHtml(t.account.avatar_static)), d.setAttribute("alt", `@${t.account.username}@${a} avatar`);
            let u = document.createElement("picture");
            u.appendChild(h), u.appendChild(d);
            let o = document.createElement("a");
            o.className = "avatar-link", o.setAttribute("href", t.account.url), o.setAttribute("rel", "external nofollow"), o.setAttribute("title", `View profile at @${t.account.username}@${a}`), o.appendChild(u);
            let i = document.createElement("a");
            i.className = "instance", i.setAttribute("href", t.account.url), i.setAttribute("title", `@${t.account.username}@${a}`), i.setAttribute("rel", "external nofollow"), i.textContent = a;
            let c = document.createElement("span");
            c.className = "display", c.setAttribute("itemprop", "author"), c.setAttribute("itemtype", "http://schema.org/Person"), c.innerHTML = t.account.display_name;
            let l = document.createElement("header");
            l.className = "author", l.appendChild(c), l.appendChild(i);
            let r = document.createElement("a");
            r.setAttribute("href", t.url), r.setAttribute("itemprop", "url"), r.setAttribute("title", `View comment at ${a}`), r.setAttribute("rel", "external nofollow"), r.textContent = new Date(t.created_at).toLocaleString("en-US", {
                dateStyle: "long",
                timeStyle: "short"
            });
            let m = document.createElement("time");
            m.setAttribute("datetime", t.created_at), m.appendChild(r);
            let f = document.createElement("main");
            f.setAttribute("itemprop", "text"), f.innerHTML = t.content;
            let g = document.createElement("footer");
            if (t.favourites_count > 0) {
                let e = document.createElement("a");
                e.className = "faves", e.setAttribute("href", `${t.url}/favourites`), e.setAttribute("title", `Favorites from ${a}`), e.textContent = t.favourites_count, g.appendChild(e)
            }
            let s = document.createElement("article");
            s.id = `comment-${t.id}`, s.className = v ? "comment comment-reply" : "comment", s.setAttribute("itemprop", "comment"), s.setAttribute("itemtype", "http://schema.org/Comment"), s.appendChild(o), s.appendChild(l), s.appendChild(m), s.appendChild(f), s.appendChild(g), p === !0 && (s.classList.add("op"), o.classList.add("op"), o.setAttribute("title", "Blog post author; " + o.getAttribute("title")), i.classList.add("op"), i.setAttribute("title", "Blog post author: " + i.getAttribute("title"))), e.innerHTML += DOMPurify.sanitize(s.outerHTML)
        }))
    })
}