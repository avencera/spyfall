module List = {
  let toggle = (list, item) => {
    switch (List.mem(item, list)) {
    | false => [item, ...list]
    | true => Belt.List.keep(list, elem => elem !== item)
    };
  };
};
